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
        case updateWorkTime(start: TimeIndicatorEntity, end: TimeIndicatorEntity)
        case requestVacation
        case changeRequestVacation
        case startWork          // 일정 있는 날 출근하기 (idle → working)
        case startWorkOnHoliday // 일정 없는 날(NONE) 쉬는날 출근하기
        case endWork
        case extendWork(end: TimeIndicatorEntity)
        case editFinishedWorkTime(start: TimeIndicatorEntity, end: TimeIndicatorEntity)
    }
    
    // MARK: - Dependencies
    
    private let homeUseCase: HomeUsecase
    
    // MARK: - Private State
    
    private var cancellables = Set<AnyCancellable>()
    private var homeEntity: HomeEntity?
    private var currentStatus: WorkStatusEntity = .idle
    
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
    
    /// type / 현재 시각 기준 자동 상태 결정
    ///
    /// - `.none`     → 시간 무관 항상 `.idle` (공휴일)
    /// - `.vacation` → 시간 이후면 `.finished`(최종완료), 그 전이면 `.idle`
    /// - `.work`     → now < inMin → `.idle`
    ///                 inMin ≤ now < outMin → `.working`
    ///                 now ≥ outMin → `.workFinished`(근무완료1)
    func resolveAutoStatus(for entity: HomeEntity) -> WorkStatusEntity {
        switch entity.type {
            
        case .none:
            // 일정 없는 날 → 항상 근무 전 공휴일 상태
            return .idle
            
        case .vacation:
            // 휴가: 퇴근 시간 이후 진입 → 최종완료
            guard let clockIn  = entity.clockInTime,
                  let clockOut = entity.clockOutTime else { return .idle }
            
            let now    = nowInMinutes()
            let inMin  = clockIn.totalMinutes
            let outMin = clockOut.totalMinutes
            
            if now < inMin {
                return .idle
            } else if now < outMin {
                return .working
            } else {
                return .finished
            }
            
        case .work:
            guard let clockIn  = entity.clockInTime,
                  let clockOut = entity.clockOutTime else { return .idle }
            
            let now    = nowInMinutes()
            let inMin  = clockIn.totalMinutes
            let outMin = clockOut.totalMinutes
            
            if now < inMin {
                return .idle
            } else if now < outMin {
                return .working
            } else {
                // 퇴근 시간 이후 → 근무완료 1 (최종완료 전 단계)
                return .workFinished
            }
        }
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
        
        // 출근 전으로 시간 변경 시 → idle로 되돌림
        if start.totalMinutes > nowInMinutes(), currentStatus.isActive {
            currentStatus = .idle
        }
        
        Task { @MainActor in
            do {
                let updated = try await homeUseCase.updateWorkday(
                    date: todayDateString(),
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
                    date: todayDateString(),
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
                    date: todayDateString(),
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
    
    /// 일정 있는 날 idle → working (버튼 탭)
    func handleStartWork() {
        guard currentStatus == .idle,
              var entity = homeEntity,
              let originalIn  = entity.clockInTime,
              let originalOut = entity.clockOutTime
        else { return }
        
        let nowMinutes = nowInMinutes()
        let originalInMinutes  = originalIn.totalMinutes
        let originalOutMinutes = originalOut.totalMinutes
        
        // 이미 예정 출근시간 이후라면 시간 조정 없이 working만
        guard nowMinutes < originalInMinutes else {
            currentStatus = .working
            publish()
            return
        }
        
        // 얼마나 일찍 출근했는지 차이 계산
        let diff = originalInMinutes - nowMinutes
        
        // 퇴근시간도 동일하게 당김
        let newOutMinutes = max(originalOutMinutes - diff, nowMinutes)
        
        let newClockIn = TimeIndicatorEntity(
            hour: nowMinutes / 60,
            minute: nowMinutes % 60
        )
        
        let newClockOut = TimeIndicatorEntity(
            hour: newOutMinutes / 60,
            minute: newOutMinutes % 60
        )
        
        Task { @MainActor in
            do {
                let updated = try await homeUseCase.updateWorkday(
                    date: todayDateString(),
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
    
    /// 일정 없는 날(NONE) 쉬는날 출근하기
    /// - 현재 시각을 clockIn, +3시간을 clockOut으로 WORK 신규 생성
    func handleStartWorkOnHoliday() {
        guard var entity = homeEntity else {
            state = .error(.dataCorrupted); return
        }
        
        let nowComponents = Calendar.korea.dateComponents([.hour, .minute], from: Date())
        let nowHour       = nowComponents.hour   ?? 9
        let nowMinute     = nowComponents.minute ?? 0
        let clockIn       = TimeIndicatorEntity(hour: nowHour, minute: nowMinute)
        
        // +3시간 계산 (24시 넘어가면 23:59 클램프)
        let endTotalMinutes = min(clockIn.totalMinutes + 180, 23 * 60 + 59)
        let clockOut = TimeIndicatorEntity(
            hour:   endTotalMinutes / 60,
            minute: endTotalMinutes % 60
        )
        
        Task { @MainActor in
            do {
                let created = try await homeUseCase.updateWorkday(
                    date: todayDateString(),
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
        
        let now    = Calendar.korea.dateComponents([.hour, .minute], from: Date())
        let endTime   = TimeIndicatorEntity(hour: now.hour ?? 0, minute: now.minute ?? 0)
        let startTime = entity.clockInTime ?? TimeIndicatorEntity(hour: 9, minute: 0)
        
        Task { @MainActor in
            do {
                let updated = try await homeUseCase.updateWorkday(
                    date: todayDateString(),
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
        
        let originalInMinutes  = originalIn.totalMinutes
        let originalOutMinutes = originalOut.totalMinutes
        
        Task { @MainActor in
            do {
                let updated = try await homeUseCase.updateWorkday(
                    date: todayDateString(),
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
        
        let nowMinutes = nowInMinutes()
        let originalInMinutes  = originalIn.totalMinutes
        let originalOutMinutes = originalOut.totalMinutes
        
        // 이미 예정 출근시간 이후라면 시간 조정 없이 working만
        guard nowMinutes < originalInMinutes else {
            currentStatus = .working
            publish()
            return
        }
        
        // 얼마나 일찍 출근했는지 차이 계산
        let diff = originalInMinutes - nowMinutes
        
        // 퇴근시간도 동일하게 당김
        let newOutMinutes = max(originalOutMinutes - diff, nowMinutes)
        
        let newClockIn = TimeIndicatorEntity(
            hour: nowMinutes / 60,
            minute: nowMinutes % 60
        )
        
        let newClockOut = TimeIndicatorEntity(
            hour: newOutMinutes / 60,
            minute: newOutMinutes % 60
        )
        
        Task { @MainActor in
            do {
                let updated = try await homeUseCase.updateWorkday(
                    date: todayDateString(),
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

// MARK: - Helpers

private extension WorkViewModel {
    
    func nowInMinutes() -> Int {
        let c = Calendar.korea.dateComponents([.hour, .minute], from: Date())
        return (c.hour ?? 0) * 60 + (c.minute ?? 0)
    }
    
    func todayDateString() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale     = Locale(identifier: "ko_KR")
        f.timeZone   = TimeZone(identifier: "Asia/Seoul")
        return f.string(from: Date())
    }
}
