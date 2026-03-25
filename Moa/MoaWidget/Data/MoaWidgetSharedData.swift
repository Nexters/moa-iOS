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

    static var isAccessible: Bool {
        userDefaults != nil
    }
}

// MARK: - 위젯 표시 상태

enum MoaWidgetStatus: String, Codable, Equatable {
    case working
    case vacation
    case finished
    case skeleton
    case offline
    case lowPower
}

// MARK: - 위젯 공유 데이터

struct MoaWidgetData: Codable, Equatable {
    var status:         MoaWidgetStatus
    var displayAmount:  Int
    var updatedAt:      Date

    var clockInMinutes:  Int?
    var clockOutMinutes: Int?
    var dailyPay:        Int?

    static let skeleton = MoaWidgetData(status: .skeleton, displayAmount: 0, updatedAt: .now)
}

// MARK: - UserDefaults 저장 / 불러오기

extension MoaWidgetData {

    private static let key = "moa.widget.data.v1"

    func save() {
        guard let encoded = try? JSONEncoder().encode(self),
              let ud = MoaAppGroup.userDefaults else { return }
        ud.set(encoded, forKey: Self.key)
    }

    static func load() -> MoaWidgetData {
        guard let ud  = MoaAppGroup.userDefaults,
              let raw = ud.data(forKey: key),
              let data = try? JSONDecoder().decode(MoaWidgetData.self, from: raw)
        else { return .skeleton }
        return data
    }
}
