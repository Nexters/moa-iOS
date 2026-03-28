//
//  WorkViewModel.swift
//  Moa
//

import UIKit
import Combine

// MARK: - WorkViewModel

final class WorkViewModel {
    
    // MARK: - Output
    
    @Published private(set) var state: WorkViewState = .idle
    
    // MARK: - Input
    
    enum Input {
        case viewDidLoad
        case refresh
        case updateWorkTime(start: TimeIndicatorEntity, end: TimeIndicatorEntity)
        case requestVacation
        case changeRequestVacation
        case startWork
        case startWorkOnHoliday
        case endWork
        case extendWork(end: TimeIndicatorEntity)
        case editFinishedWorkTime(start: TimeIndicatorEntity, end: TimeIndicatorEntity)
        case confirmWork
    }
    
    // MARK: - Dependencies
    
    private let homeUseCase: HomeUsecase
    
    // MARK: - Private State
    
    private var cancellables   = Set<AnyCancellable>()
    private var homeEntity:      HomeEntity?
    private var currentStatus:   WorkStatusEntity = .idle
    
    // MARK: - Init
    
    init(homeUseCase: HomeUsecase) {
        self.homeUseCase = homeUseCase
    }
    
    deinit { cancellables.removeAll() }
}

// MARK: - Public Interface

extension WorkViewModel {
    
    func send(_ input: Input) {
        switch input {
        case .viewDidLoad:
            loadInitialData()
        case .refresh:
            refreshData()
        case let .updateWorkTime(start, end):
            handleUpdateWorkTime(start: start, end: end)
        case .requestVacation:
            handleRequestVacation()
        case .changeRequestVacation:
            changeRequestVacation()
        case .startWork:
            handleStartWork()
        case .startWorkOnHoliday:
            handleStartWorkOnHoliday()
        case .endWork:
            handleEndWork()
        case let .extendWork(end):
            handleExtendWork(end: end)
        case let .editFinishedWorkTime(start, end):
            handleEditFinishedWorkTime(start: start, end: end)
        case .confirmWork:
            handleConfirmWork()
        }
    }
}

// MARK: - Data Loading

private extension WorkViewModel {
    
    func loadInitialData() {
        guard state != .loading else { return }
        state = .loading
        loadHomeData()
    }

    func refreshData() {
        loadHomeData()
    }
    
    func loadHomeData() {
        Task { @MainActor in
            do {
                let entity = try await homeUseCase.getHomeData()
                apply(entity)
            } catch {
                state = .error(.network)
            }
        }
    }
    
    func apply(_ entity: HomeEntity) {
        homeEntity    = entity
        currentStatus = resolveAutoStatus(for: entity)
        publish()
    }
}

// MARK: - Auto Status Resolution

private extension WorkViewModel {
    
    /// type / 현재 시각 / 오늘 확인 여부 기준 자동 상태 결정
    ///
    /// - `.none`     → 항상 `.idle`
    /// - `.vacation` → 시각 기준 idle / working / finished
    /// - `.work`     → 오늘 이미 확인했으면 즉시 `.finished`
    ///                 퇴근 시각 이후면 `.workFinished`
    ///                 근무 중이면 `.working`
    ///                 출근 전이면 `.idle`
    func resolveAutoStatus(for entity: HomeEntity) -> WorkStatusEntity {
        switch entity.type {
            
        case .none:
            return .idle
            
        case .vacation:
            guard let clockIn  = entity.clockInTime,
                  let clockOut = entity.clockOutTime else { return .idle }
            
            let now    = Date().minutesFromMidnight
            let inMin  = clockIn.totalMinutes
            let outMin = clockOut.totalMinutes
            
            if now < inMin        { return .idle }
            else if now < outMin  { return .working }
            else                  { return .finished }
            
        case .work:
            guard let clockIn  = entity.clockInTime,
                  let clockOut = entity.clockOutTime else { return .idle }
            
            let now    = Date().minutesFromMidnight
            let inMin  = clockIn.totalMinutes
            let outMin = clockOut.totalMinutes
            
            if now < inMin {
                return .idle
            } else if now < outMin {
                return .working
            } else {
                // 퇴근 시각 이후 — 오늘 이미 "완료" 버튼을 탭했으면 즉시 .finished
                if WorkConfirmStorage.isConfirmedToday {
                    return .finished
                }
                return .workFinished
            }
        }
    }
}

// MARK: - Confirm Work

private extension WorkViewModel {

    /// "완료" 버튼 탭 처리
    func handleConfirmWork() {
        WorkConfirmStorage.markConfirmedToday()
        currentStatus = .finished
        publish()
    }
}

// MARK: - Work Time Adjustment

private extension WorkViewModel {
    
    func handleUpdateWorkTime(start: TimeIndicatorEntity, end: TimeIndicatorEntity) {
        guard var entity = homeEntity else {
            state = .error(.dataCorrupted); return
        }
        guard start.totalMinutes < end.totalMinutes else {
            state = .error(.invalidWorkTime); return
        }
        
        if start.totalMinutes > Date().minutesFromMidnight, currentStatus.isActive {
            currentStatus = .idle
        }
        
        Task { @MainActor in
            do {
                let updated = try await homeUseCase.updateWorkday(
                    date: Date().dateString,
                    type: .work,
                    clockInTime: start,
                    clockOutTime: end
                )
                applyWorkdayUpdate(updated, to: &entity)
                homeEntity = entity
                apply(entity)
            } catch {
                state = .error(.network)
            }
        }
    }
    
    func handleExtendWork(end: TimeIndicatorEntity) {
        guard var entity = homeEntity else {
            state = .error(.dataCorrupted); return
        }
        Task { @MainActor in
            do {
                let updated = try await homeUseCase.updateClockOutTime(
                    date: Date().dateString,
                    clockOutTime: end
                )
                applyWorkdayUpdate(updated, to: &entity)
                homeEntity = entity
                apply(entity)
            } catch {
                state = .error(.network)
            }
        }
    }
    
    func handleEditFinishedWorkTime(start: TimeIndicatorEntity, end: TimeIndicatorEntity) {
        guard var entity = homeEntity else {
            state = .error(.dataCorrupted); return
        }
        guard start.totalMinutes < end.totalMinutes else {
            state = .error(.invalidWorkTime); return
        }
        Task { @MainActor in
            do {
                let updated = try await homeUseCase.updateWorkday(
                    date: Date().dateString,
                    type: .work,
                    clockInTime: start,
                    clockOutTime: end
                )
                applyWorkdayUpdate(updated, to: &entity)
                homeEntity = entity
                apply(entity)
            } catch {
                state = .error(.network)
            }
        }
    }
    
    func applyWorkdayUpdate(_ workday: WorkdayEntity, to entity: inout HomeEntity) {
        entity = HomeEntity(
            workplace:      entity.workplace,
            workedEarnings: entity.workedEarnings,
            standardSalary: entity.standardSalary,
            dailyPay:       entity.dailyPay,
            type:           workday.type,
            clockInTime:    workday.clockInTime,
            clockOutTime:   workday.clockOutTime
        )
    }
}

// MARK: - Work Session Control

private extension WorkViewModel {
    
    func handleStartWork() {
        guard currentStatus == .idle,
              var entity = homeEntity,
              let originalIn  = entity.clockInTime,
              let originalOut = entity.clockOutTime
        else { return }
        
        let nowMinutes         = Date().minutesFromMidnight
        let originalInMinutes  = originalIn.totalMinutes
        let originalOutMinutes = originalOut.totalMinutes
        
        guard nowMinutes < originalInMinutes else {
            currentStatus = .working
            publish()
            return
        }
        
        let diff          = originalInMinutes - nowMinutes
        let newOutMinutes = max(originalOutMinutes - diff, nowMinutes)
        
        let newClockIn  = TimeIndicatorEntity(hour: nowMinutes / 60,   minute: nowMinutes % 60)
        let newClockOut = TimeIndicatorEntity(hour: newOutMinutes / 60, minute: newOutMinutes % 60)
        
        Task { @MainActor in
            do {
                let updated = try await homeUseCase.updateWorkday(
                    date: Date().dateString,
                    type: entity.type,
                    clockInTime: newClockIn,
                    clockOutTime: newClockOut
                )
                applyWorkdayUpdate(updated, to: &entity)
                homeEntity    = entity
                currentStatus = .working
                publish()
            } catch {
                state = .error(.network)
            }
        }
    }
    
    func handleStartWorkOnHoliday() {
        guard var entity = homeEntity else {
            state = .error(.dataCorrupted); return
        }
        
        let nowMinutes      = Date().minutesFromMidnight
        let clockIn         = TimeIndicatorEntity(hour: nowMinutes / 60, minute: nowMinutes % 60)
        let endTotalMinutes = min(clockIn.totalMinutes + 180, 23 * 60 + 59)
        let clockOut        = TimeIndicatorEntity(hour: endTotalMinutes / 60, minute: endTotalMinutes % 60)
        
        Task { @MainActor in
            do {
                let created = try await homeUseCase.updateWorkday(
                    date: Date().dateString,
                    type: .work,
                    clockInTime: clockIn,
                    clockOutTime: clockOut
                )
                applyWorkdayUpdate(created, to: &entity)
                homeEntity    = entity
                currentStatus = .working
                publish()
            } catch {
                state = .error(.network)
            }
        }
    }
    
    func handleEndWork() {
        guard currentStatus.isActive,
              var entity = homeEntity else { return }
        
        let nowMinutes = Date().minutesFromMidnight
        let endTime    = TimeIndicatorEntity(hour: nowMinutes / 60, minute: nowMinutes % 60)
        let startTime  = entity.clockInTime ?? TimeIndicatorEntity(hour: 9, minute: 0)
        
        Task { @MainActor in
            do {
                let updated = try await homeUseCase.updateWorkday(
                    date: Date().dateString,
                    type: entity.type,
                    clockInTime: startTime,
                    clockOutTime: endTime
                )
                applyWorkdayUpdate(updated, to: &entity)
                homeEntity    = entity
                currentStatus = entity.type == .vacation ? .finished : .workFinished
                publish()
            } catch {
                state = .error(.network)
            }
        }
    }
    
    func changeRequestVacation() {
        guard currentStatus == .working,
              var entity = homeEntity,
              let originalIn  = entity.clockInTime,
              let originalOut = entity.clockOutTime
        else { return }
        
        Task { @MainActor in
            do {
                let updated = try await homeUseCase.updateWorkday(
                    date: Date().dateString,
                    type: .vacation,
                    clockInTime: originalIn,
                    clockOutTime: originalOut
                )
                applyWorkdayUpdate(updated, to: &entity)
                homeEntity    = entity
                currentStatus = .working
                publish()
            } catch {
                state = .error(.network)
            }
        }
    }
    
    func handleRequestVacation() {
        guard currentStatus == .idle,
              var entity = homeEntity,
              let originalIn  = entity.clockInTime,
              let originalOut = entity.clockOutTime
        else { return }
        
        let nowMinutes         = Date().minutesFromMidnight
        let originalInMinutes  = originalIn.totalMinutes
        let originalOutMinutes = originalOut.totalMinutes
        
        guard nowMinutes < originalInMinutes else {
            currentStatus = .working
            publish()
            return
        }
        
        let diff          = originalInMinutes - nowMinutes
        let newOutMinutes = max(originalOutMinutes - diff, nowMinutes)
        
        let newClockIn  = TimeIndicatorEntity(hour: nowMinutes / 60,   minute: nowMinutes % 60)
        let newClockOut = TimeIndicatorEntity(hour: newOutMinutes / 60, minute: newOutMinutes % 60)
        
        Task { @MainActor in
            do {
                let updated = try await homeUseCase.updateWorkday(
                    date: Date().dateString,
                    type: .vacation,
                    clockInTime: newClockIn,
                    clockOutTime: newClockOut
                )
                applyWorkdayUpdate(updated, to: &entity)
                homeEntity    = entity
                currentStatus = .working
                publish()
            } catch {
                state = .error(.network)
            }
        }
    }
}

// MARK: - Publish

private extension WorkViewModel {
    
    func publish() {
        guard let entity = homeEntity else {
            state = .error(.dataCorrupted); return
        }
        state = .loaded(status: currentStatus, data: entity)
        MoaWidgetUpdater.sync(status: currentStatus, entity: entity)
    }
}
