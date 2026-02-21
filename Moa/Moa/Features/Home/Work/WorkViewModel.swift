//
//  WorkViewModel.swift
//  Moa
//

import UIKit
import Combine

// MARK: - WorkViewModel

final class WorkViewModel {

    // MARK: Output

    @Published private(set) var state: WorkViewState = .idle

    // MARK: Input

    enum Input {
        case viewDidLoad
        case updateWorkTime(start: TimeIndicatorEntity, end: TimeIndicatorEntity)
        case startWork
        case endWork
        case requestVacation
    }

    // MARK: Private

    private var cancellables  = Set<AnyCancellable>()

    // 원본 도메인 데이터 보관 (업데이트 시 재조합용)
    private var currentSchedule: WorkSchedule?
    private var currentSalary:   SalarySummary?
    private var currentStatus:   WorkStatus = .idle

    deinit { cancellables.removeAll() }
}

// MARK: - Public Interface

extension WorkViewModel {

    func send(_ input: Input) {
        switch input {
        case .viewDidLoad:                        loadInitialData()
        case let .updateWorkTime(start, end):     handleUpdateWorkTime(start: start, end: end)
        case .startWork:                          handleStartWork()
        case .endWork:                            handleEndWork()
        case .requestVacation:                    handleRequestVacation()
        }
    }
}

// MARK: - Data Loading

private extension WorkViewModel {

    func loadInitialData() {
        guard state != .loading else { return }
        state = .loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.loadMockData()
        }
    }

    func loadMockData() {
        let scheduleDTO = WorkScheduleDTO(
            date: "2026-02-21",
            type: .work,
            clockInTime:  "20:00",
            clockOutTime: "24:00"
        )
        let salaryDTO = SalaryDTO(salaryInputType: .monthly, salaryAmount: 3_300_000)

        guard let schedule = WorkSchedule(dto: scheduleDTO, workplace: "을지로") else {
            state = .error(.dataCorrupted)
            return
        }
        let salary = SalarySummary(dto: salaryDTO)

        currentSchedule = schedule
        currentSalary   = salary

        // 현재 시각 기준으로 WorkStatus 자동 결정
        currentStatus = resolveAutoStatus(for: schedule)
        publish()
    }
}

// MARK: - Work Time Adjustment

private extension WorkViewModel {

    func handleUpdateWorkTime(start: TimeIndicatorEntity, end: TimeIndicatorEntity) {
        guard var schedule = currentSchedule else {
            state = .error(.dataCorrupted); return
        }
        guard start.totalMinutes < end.totalMinutes else {
            state = .error(.invalidWorkTime); return
        }

        // 스케줄 shift 교체
        let newShift = WorkShift(
            clockIn:  WorkTime(hour: start.hour, minute: start.minute),
            clockOut: WorkTime(hour: end.hour,   minute: end.minute)
        )
        schedule = WorkSchedule(date: schedule.date, kind: schedule.kind,
                                shift: newShift, workplace: schedule.workplace)
        currentSchedule = schedule

        // 새 clockIn이 현재 시각보다 이후이면 근무 전(idle)으로 복귀
        if start.totalMinutes > nowInMinutes(), currentStatus.isActive {
            currentStatus = .idle
        }
        publish()
    }
}

// MARK: - Work Session Control

private extension WorkViewModel {

    func handleStartWork() {
        guard case .idle = currentStatus else { return }
        currentStatus = .working(startedAt: Date())
        publish()
    }

    func handleEndWork() {
        guard currentStatus.isActive else { return }
        currentStatus = .finished(finishedAt: Date())
        publish()
    }

    func handleRequestVacation() {
        switch currentStatus {
        case .idle:
            // 출근 전 "오늘 휴가에요" → 바로 vacation WorkingContentView 진입
            currentStatus = .onVacation(startedAt: Date())
            // 스케줄 kind도 vacation으로 전환
            if let schedule = currentSchedule {
                currentSchedule = WorkSchedule(
                    date: schedule.date, kind: .vacation,
                    shift: schedule.shift, workplace: schedule.workplace
                )
            }

        case .working(let startedAt):
            // 근무 중 → 휴가 전환 (startedAt 유지)
            currentStatus = .onVacation(startedAt: startedAt)

        default:
            break
        }
        publish()
    }
}

// MARK: - Auto Session Resolution

private extension WorkViewModel {

    /// 앱 진입 시 현재 시각 기준으로 WorkStatus 자동 결정
    ///
    /// - clockIn ≤ 현재 < clockOut  →  근무/휴가 중 (스케줄 kind에 따라)
    ///   - startedAt = 실제 clockIn Date → 경과 시간 = 현재 - clockIn = 정확한 값
    /// - 현재 ≥ clockOut            →  finished
    /// - 현재 < clockIn             →  idle
    func resolveAutoStatus(for schedule: WorkSchedule) -> WorkStatus {
        guard let shift = schedule.shift, schedule.kind != .holiday else {
            return .idle
        }

        let now      = nowInMinutes()
        let clockIn  = shift.clockIn.totalMinutes
        let clockOut = shift.clockOut.totalMinutes

        if now >= clockIn && now < clockOut {
            // startedAt을 실제 clockIn 시각으로 생성 → 타이머가 08:xx ~ 현재까지 정확히 표시
            let startedAt = makeDate(hour: shift.clockIn.hour, minute: shift.clockIn.minute)
            return schedule.kind == .vacation
                ? .onVacation(startedAt: startedAt)
                : .working(startedAt: startedAt)

        } else if now >= clockOut {
            let finishedAt = makeDate(hour: shift.clockOut.hour, minute: shift.clockOut.minute)
            return .finished(finishedAt: finishedAt)
        }

        return .idle
    }
}

// MARK: - Publish

private extension WorkViewModel {

    func publish() {
        guard let schedule = currentSchedule,
              let salary   = currentSalary
        else {
            state = .error(.dataCorrupted)
            return
        }

        let display = buildDisplayData(schedule: schedule, salary: salary, status: currentStatus)
        state = .loaded(display)
    }

    func buildDisplayData(
        schedule: WorkSchedule,
        salary: SalarySummary,
        status: WorkStatus
    ) -> HomeDisplayData {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 (E)"
        formatter.locale = Locale(identifier: "ko_KR")

        let shift = schedule.shift
        let clockIn  = TimeIndicatorEntity(
            hour:   shift?.clockIn.hour   ?? 9,
            minute: shift?.clockIn.minute ?? 0
        )
        let clockOut = TimeIndicatorEntity(
            hour:   shift?.clockOut.hour   ?? 18,
            minute: shift?.clockOut.minute ?? 0
        )

        return HomeDisplayData(
            formattedDate:    formatter.string(from: schedule.date),
            workplace:        schedule.workplace,
            scheduledClockIn:  clockIn,
            scheduledClockOut: clockOut,
            dailyWage:        salary.dailyWage,
            hourlyWage:       salary.hourlyWage,
            scheduleStatus:   resolveScheduleStatus(kind: schedule.kind, workStatus: status),
            workStatus:       status
        )
    }

    /// WorkScheduleKind + WorkStatus → HomeScheduleStatus (화면 상태)
    func resolveScheduleStatus(kind: WorkScheduleKind, workStatus: WorkStatus) -> HomeScheduleStatus {
        switch kind {
        case .holiday:  return .holiday
        case .vacation: return .onVacation
        case .regular:
            switch workStatus {
            case .idle, .working:         return .beforeWork
            case .onVacation:             return .onVacation
            case .finished:               return .afterWork
            }
        }
    }
}

// MARK: - Helpers

private extension WorkViewModel {

    func nowInMinutes() -> Int {
        let c = Calendar.current.dateComponents([.hour, .minute], from: Date())
        return (c.hour ?? 0) * 60 + (c.minute ?? 0)
    }

    func makeDate(hour: Int, minute: Int) -> Date {
        var c = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        c.hour = hour; c.minute = minute; c.second = 0
        return Calendar.current.date(from: c) ?? Date()
    }
}
