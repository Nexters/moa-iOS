//
//  MoaWidgetSharedData.swift
//  Moa
//

import Foundation

// MARK: - App Group

enum MoaAppGroup {
    static let identifier = "group.kr.co.nexters.ios.moa"

    static var userDefaults: UserDefaults? {
        UserDefaults(suiteName: identifier)
    }

    /// 디버그용 — App Group 접근 가능 여부 확인
    static var isAccessible: Bool {
        userDefaults != nil
    }
}

// MARK: - 위젯 표시 상태

enum MoaWidgetStatus: String, Codable, Equatable {
    case working    // 근무 중       — 오늘 번 금액 + 업데이트 시각
    case vacation   // 휴가 중       — 오늘 번 금액 + 업데이트 시각
    case finished   // 근무완료/주말  — 이번달 누적 월급
    case skeleton   // 데이터 없음   — 플레이스홀더
    case offline    // 네트워크 없음 — 안내 메시지
    case lowPower   // 절전 모드     — 안내 메시지
}

// MARK: - 위젯 공유 데이터

struct MoaWidgetData: Codable, Equatable {
    var status:         MoaWidgetStatus
    var displayAmount:  Int
    var updatedAt:      Date

    /// 근무 중 / 휴가일 때만 채워짐 — RefreshWidgetIntent에서 정확한 금액 재계산에 사용
    var clockInMinutes:  Int?
    var clockOutMinutes: Int?
    var dailyPay:        Int?

    static let skeleton = MoaWidgetData(status: .skeleton, displayAmount: 0, updatedAt: .now)
}

// MARK: - UserDefaults 저장 / 불러오기

extension MoaWidgetData {

    private static let key = "moa.widget.data.v1"

    func save() {
        guard let encoded = try? JSONEncoder().encode(self) else {
            print("[MoaWidget] ❌ encode 실패")
            return
        }
        guard let ud = MoaAppGroup.userDefaults else {
            return
        }
        ud.set(encoded, forKey: Self.key)
        ud.synchronize()
    }

    static func load() -> MoaWidgetData {
        guard let ud = MoaAppGroup.userDefaults else {
            return .skeleton
        }
        guard let raw = ud.data(forKey: key) else {
            return .skeleton
        }
        guard let data = try? JSONDecoder().decode(MoaWidgetData.self, from: raw) else {
            return .skeleton
        }
        return data
    }
}
