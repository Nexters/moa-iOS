//
//  AnalyticsEvent.swift
//  Moa
//
//  Created by mirim on 5/3/26.
//

import Foundation

enum AnalyticsEvent {
    case loginButtonClicked(oauthtype: AccountProvider)
    case nicknameNextClicked(isModified: Bool)
    
    var name: String {
        switch self {
        case .loginButtonClicked: "login_button_clicked"
        case .nicknameNextClicked: "nickname_next_clicked"
        }
    }
    
    var properties: [String: Any] {
        switch self {
        case let .loginButtonClicked(oauthtype):
            return ["oauthtype": oauthtype.trackingName]
        case let .nicknameNextClicked(isModified):
            return ["is_modified": isModified]
        }
    }
}

