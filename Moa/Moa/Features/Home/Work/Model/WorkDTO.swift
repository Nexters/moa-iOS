//
//  WorkDTO.swift
//  Moa
//
//  Created by 정도현 on 2/21/26.
//

import Foundation

// MARK: - WorkScheduleDTO

/// 근무일/스케줄 API 응답 (`content` 래퍼 내부)
struct WorkScheduleDTO: Decodable {
    let date: String            // "2026-02-20"
    let type: ScheduleTypeRaw   // "WORK" | "HOLIDAY" | "VACATION"
    let clockInTime: String?    // "09:00" — nullable (휴일은 없음)
    let clockOutTime: String?   // "18:00"
}

/// API raw string → 도메인 변환 전 타입
enum ScheduleTypeRaw: String, Decodable {
    case work     = "WORK"
    case holiday  = "HOLIDAY"
    case vacation = "VACATION"
}

// MARK: - SalaryDTO

/// 급여정보 API 응답
struct SalaryDTO: Decodable {
    let salaryInputType: SalaryTypeRaw
    let salaryAmount: Int
}

/// API raw string → 도메인 변환 전 타입
enum SalaryTypeRaw: String, Decodable {
    case annual  = "ANNUAL"
    case monthly = "MONTHLY"
    case hourly  = "HOURLY"
}
