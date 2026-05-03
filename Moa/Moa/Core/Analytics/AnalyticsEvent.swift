//
//  AnalyticsEvent.swift
//  Moa
//
//  Created by mirim on 5/3/26.
//

import Foundation

/// 사용자 행동 이벤트 - Analytics.track(:)으로 전송
enum AnalyticsEvent {
    case loginButtonClicked(oauthtype: AccountProvider)
    case nicknameNextClicked(isModified: Bool)
    case salaryNextClicked(isModified: Bool)
    case workPolicyNextClicked(isModified: Bool)
    
    var name: String {
        switch self {
        case .loginButtonClicked: "login_button_clicked"
        case .nicknameNextClicked: "nickname_next_clicked"
        case .salaryNextClicked: "salary_next_clicked"
        case .workPolicyNextClicked: "work_policy_next_clicked"
        }
    }
    
    var properties: [String: Any] {
        switch self {
        case let .loginButtonClicked(oauthtype):
            return ["oauthtype": oauthtype.trackingName]
        case let .nicknameNextClicked(isModified):
            return ["is_modified": isModified]
        case let .salaryNextClicked(isModified):
            return ["is_modified": isModified]
        case let .workPolicyNextClicked(isModified):
            return ["is_modified": isModified]
        }
    }
}

