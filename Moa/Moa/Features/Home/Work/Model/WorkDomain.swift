//
//  WorkDomain.swift
//  Moa
//
//  Created by 정도현 on 2/21/26.
//

import UIKit

// MARK: - WorkSchedule (도메인)

/// 특정 날짜의 근무 스케줄
struct WorkSchedule {
    let date: Date
    let kind: WorkScheduleKind
    let shift: WorkShift?           // holiday에는 nil
    let workplace: String?
}

/// 스케줄 종류
enum WorkScheduleKind: Equatable {
    case regular    // 일반 근무일 (WORK)
    case holiday    // 공휴일/쉬는날 (HOLIDAY)
    case vacation   // 휴가 (VACATION)
}

/// 출퇴근 시간 쌍
struct WorkShift: Equatable {
    let clockIn: WorkTime
    let clockOut: WorkTime
}

/// 시:분 값 타입 (TimeIndicatorEntity의 도메인 대응)
struct WorkTime: Equatable {
    let hour: Int
    let minute: Int

    /// "09:00" 형식 파싱
    init?(timeString: String) {
        let parts = timeString.split(separator: ":").compactMap { Int($0) }
        guard parts.count == 2 else { return nil }
        self.hour   = parts[0]
        self.minute = parts[1]
    }

    init(hour: Int, minute: Int) {
        self.hour   = hour
        self.minute = minute
    }

    var totalMinutes: Int { hour * 60 + minute }

    /// "09:00" 형태
    var displayString: String { String(format: "%02d:%02d", hour, minute) }
}

// MARK: - SalarySummary (도메인)

/// 급여 정책 + 계산 로직을 캡슐화한 도메인 모델
struct SalarySummary {
    let policy: SalaryPolicy
    let baseAmount: Int     // API에서 받은 원본 금액 (연봉/월급/시급)
}

/// 급여 입력 방식
enum SalaryPolicy: Equatable {
    case annual             // 연봉
    case monthly            // 월급
    case hourly             // 시급

    // MARK: - 계산

    /// 일급 (기본 근무일 22일, 8시간 기준)
    func dailyWage(from amount: Int) -> Int {
        switch self {
        case .annual:  return amount / 12 / 22
        case .monthly: return amount / 22
        case .hourly:  return amount * 8
        }
    }

    /// 시급
    func hourlyWage(from amount: Int) -> Int {
        switch self {
        case .annual:  return amount / 12 / 22 / 8
        case .monthly: return amount / 22 / 8
        case .hourly:  return amount
        }
    }
}

extension SalarySummary {
    var dailyWage: Int  { policy.dailyWage(from: baseAmount) }
    var hourlyWage: Int { policy.hourlyWage(from: baseAmount) }
}

// MARK: - WorkSession (도메인 런타임 상태)

/// 당일 근무 세션의 런타임 상태 (API와 무관하게 앱이 관리)
enum WorkSession: Equatable {
    case notStarted                         // 출근 전
    case inProgress(startedAt: Date)        // 근무 중
    case onVacation(startedAt: Date)        // 근무 중 휴가 전환
    case completed(finishedAt: Date)        // 퇴근 완료

    var isActive: Bool {
        switch self {
        case .inProgress, .onVacation: return true
        default:                       return false
        }
    }

    var startedAt: Date? {
        switch self {
        case .inProgress(let d), .onVacation(let d): return d
        default:                                     return nil
        }
    }
}

// MARK: - DTO → Domain 변환

extension WorkSchedule {
    /// DTO + 부가 정보 → 도메인 변환
    init?(dto: WorkScheduleDTO, workplace: String?) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dto.date) else { return nil }

        self.date      = date
        self.workplace = workplace
        self.kind      = WorkScheduleKind(raw: dto.type)

        if let inStr  = dto.clockInTime,
           let outStr = dto.clockOutTime,
           let clockIn  = WorkTime(timeString: inStr),
           let clockOut = WorkTime(timeString: outStr) {
            self.shift = WorkShift(clockIn: clockIn, clockOut: clockOut)
        } else {
            self.shift = nil
        }
    }
}

extension WorkScheduleKind {
    init(raw: ScheduleTypeRaw) {
        switch raw {
        case .work:     self = .regular
        case .holiday:  self = .holiday
        case .vacation: self = .vacation
        }
    }
}

extension SalarySummary {
    init(dto: SalaryDTO) {
        self.policy     = SalaryPolicy(raw: dto.salaryInputType)
        self.baseAmount = dto.salaryAmount
    }
}

extension SalaryPolicy {
    init(raw: SalaryTypeRaw) {
        switch raw {
        case .annual:  self = .annual
        case .monthly: self = .monthly
        case .hourly:  self = .hourly
        }
    }
}


// MARK: - WorkingType

enum WorkingType {
    case work
    case vacation

    var stackImage: UIImage {
        switch self {
        case .work:     return UIImage(resource: .Image.imgWorkingMoneyStack)
        case .vacation: return UIImage(resource: .Image.imgVacationMoneyStack)
        }
    }

    var barColor: UIColor {
        switch self {
        case .work:     return AppColor.IconAndText.green
        case .vacation: return AppColor.IconAndText.blue
        }
    }

    var badgeType: BadgeType {
        switch self {
        case .work:     return .working
        case .vacation: return .vacation
        }
    }
}

// MARK: - HomeScheduleStatus
//
// 뷰 레이어에서 사용하는 화면 상태 타입.
// WorkScheduleKind + WorkSession을 조합해 ViewModel이 결정합니다.

enum HomeScheduleStatus: Equatable {
    case beforeWork   // 출근 전
    case afterWork    // 퇴근 후
    case onVacation   // 휴가
    case holiday      // 공휴일

    var moneyImage: UIImage {
        switch self {
        case .beforeWork:           return UIImage(resource: .Image.imgEmptyMoney)
        case .afterWork, .onVacation: return UIImage(resource: .Image.imgFullMoney)
        case .holiday:              return UIImage(resource: .Image.imgVacationMoney)
        }
    }

    var accentColor: UIColor {
        switch self {
        case .holiday: return AppColor.IconAndText.blue
        default:       return AppColor.IconAndText.green
        }
    }

    var primaryButtonTitle: String {
        switch self {
        case .beforeWork:               return "지금 출근하기"
        case .afterWork, .onVacation:   return "이번달 근무 기록 확인하기"
        case .holiday:                  return "쉬는날 출근하기"
        }
    }

    var wagePrefix: String? {
        self == .afterWork ? "+ " : nil
    }

    var showsWageDescription: Bool {
        self == .beforeWork
    }

    var showsVacationButton: Bool {
        self == .beforeWork
    }
}

// MARK: - HomeDisplayData
//
// ViewModel → View 단방향 데이터 전달 구조체.
// 뷰는 이 타입만 알고, WorkSchedule / WorkSession은 알지 않습니다.

struct HomeDisplayData: Equatable {
    let formattedDate: String           // "2월 21일 (토)"
    let workplace: String?
    let scheduledClockIn: TimeIndicatorEntity
    let scheduledClockOut: TimeIndicatorEntity
    let dailyWage: Int                  // 오늘 예상 일급
    let hourlyWage: Int                 // 시급 (근무 중 실시간 계산용)
    let scheduleStatus: HomeScheduleStatus
    let workStatus: WorkStatus          // 타이머·금액 계산용 런타임 상태
}

// MARK: - WorkStatus

enum WorkStatus: Equatable {
    case idle                           // 출근 전 (버튼 대기)
    case working(startedAt: Date)       // 근무 중
    case onVacation(startedAt: Date)    // 휴가 중
    case finished(finishedAt: Date)     // 퇴근 완료

    var isActive: Bool {
        switch self {
        case .working, .onVacation: return true
        default:                    return false
        }
    }

    var startedAt: Date? {
        switch self {
        case .working(let d), .onVacation(let d): return d
        default:                                  return nil
        }
    }
}

// MARK: - WorkViewState

enum WorkViewState: Equatable {
    case idle
    case loading
    case loaded(HomeDisplayData)
    case error(WorkViewError)
}

// MARK: - WorkViewError

enum WorkViewError: LocalizedError, Equatable {
    case network
    case dataCorrupted
    case unauthorized
    case invalidWorkTime
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .network:          return "네트워크 연결을 확인해주세요."
        case .dataCorrupted:    return "데이터를 처리하는 중 문제가 발생했습니다."
        case .unauthorized:     return "로그인이 필요합니다."
        case .invalidWorkTime:  return "종료 시간이 시작 시간보다 빨라요."
        case .unknown(let msg): return msg
        }
    }
}
