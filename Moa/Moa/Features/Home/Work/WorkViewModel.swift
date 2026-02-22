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
        case startWork
        case endWork
        case extendWork(end: TimeIndicatorEntity)
        case editFinishedWorkTime(start: TimeIndicatorEntity, end: TimeIndicatorEntity)
    }

    // MARK: - Dependencies

    private let homeUseCase: HomeUsecase

    // MARK: - Private State

    private var cancellables = Set<AnyCancellable>()
    private var homeEntity: HomeEntity?
    private var currentStatus: WorkStatus = .idle

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

        case .startWork:
            handleStartWork()

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
        homeEntity = entity
        currentStatus = resolveAutoStatus(for: entity)
        publish()
    }
}

// MARK: - Work Time Adjustment

private extension WorkViewModel {

    func handleUpdateWorkTime(start: TimeIndicatorEntity, end: TimeIndicatorEntity) {
        guard var entity = homeEntity else {
            state = .error(.dataCorrupted)
            return
        }

        guard start.totalMinutes < end.totalMinutes else {
            state = .error(.invalidWorkTime)
            return
        }

        if start.totalMinutes > nowInMinutes(),
           currentStatus.isActive {
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
            state = .error(.dataCorrupted)
            return
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

    func handleEditFinishedWorkTime(start: TimeIndicatorEntity,
                                    end: TimeIndicatorEntity) {
        guard var entity = homeEntity else {
            state = .error(.dataCorrupted)
            return
        }

        guard start.totalMinutes < end.totalMinutes else {
            state = .error(.invalidWorkTime)
            return
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

    func applyWorkdayUpdate(_ workday: WorkdayEntity,
                            to entity: inout HomeEntity) {

        entity = HomeEntity(
            workplace:      entity.workplace,
            workedEarnings: entity.workedEarnings,
            standardSalary: entity.standardSalary,
            dailyPay:       entity.dailyPay,
            type:           WorkdayType(serverValue: workday.type),
            clockInTime:    workday.clockInTime,
            clockOutTime:   workday.clockOutTime
        )
    }
}

// MARK: - Work Session Control

private extension WorkViewModel {

    func handleStartWork() {
        guard currentStatus == .idle else { return }
        currentStatus = .working
        publish()
    }

    func handleEndWork() {
        guard currentStatus.isActive,
              var entity = homeEntity else { return }

        let now = Calendar.korea.dateComponents([.hour, .minute],
                                                from: Date())

        guard let hour = now.hour,
              let minute = now.minute else { return }

        let endTime   = TimeIndicatorEntity(hour: hour, minute: minute)
        let startTime = entity.clockInTime
            ?? TimeIndicatorEntity(hour: 9, minute: 0)

        Task { @MainActor in
            do {
                let updated = try await homeUseCase.updateWorkday(
                    date: todayDateString(),
                    type: .work,
                    clockInTime: startTime,
                    clockOutTime: endTime
                )

                applyWorkdayUpdate(updated, to: &entity)
                homeEntity = entity
                currentStatus = .finished
                publish()
            } catch {
                state = .error(.network)
            }
        }
    }

    func handleRequestVacation() {
        guard var entity = homeEntity else { return }

        let clockIn  = entity.clockInTime
        let clockOut = entity.clockOutTime

        Task { @MainActor in
            do {
                let updated = try await homeUseCase.updateWorkday(
                    date: todayDateString(),
                    type: .vacation,
                    clockInTime: clockIn,
                    clockOutTime: clockOut
                )

                applyWorkdayUpdate(updated, to: &entity)
                homeEntity = entity
                currentStatus = .idle
                publish()
            } catch {
                state = .error(.network)
            }
        }
    }
}

// MARK: - Auto Status Resolution

private extension WorkViewModel {

    func resolveAutoStatus(for entity: HomeEntity) -> WorkStatus {
        guard entity.type == .work,
              let clockIn = entity.clockInTime,
              let clockOut = entity.clockOutTime
        else { return .idle }

        let now = nowInMinutes()
        let inMin = clockIn.totalMinutes
        let outMin = clockOut.totalMinutes

        if now >= inMin && now < outMin {
            return .working
        } else if now >= outMin {
            return .finished
        } else {
            return .idle
        }
    }
}

// MARK: - Publish

private extension WorkViewModel {

    func publish() {
        guard let entity = homeEntity else {
            state = .error(.dataCorrupted)
            return
        }

        state = .loaded(status: currentStatus,
                        data: entity)
    }
}

// MARK: - Helpers

private extension WorkViewModel {

    func nowInMinutes() -> Int {
        let c = Calendar.korea.dateComponents([.hour, .minute],
                                              from: Date())
        return (c.hour ?? 0) * 60 + (c.minute ?? 0)
    }

    func todayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter.string(from: Date())
    }
}
