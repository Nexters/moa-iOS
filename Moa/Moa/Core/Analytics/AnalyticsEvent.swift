//
//  AnalyticsEvent.swift
//  Moa
//
//  Created by mirim on 5/3/26.
//

import Foundation

enum AnalyticsEvent {
    case loginButtonClicked(oauthtype: AccountProvider)
    
    var name: String {
        switch self {
        case .loginButtonClicked: "login_button_clicked"
        }
    }
    
    var properties: [String: Any] {
        switch self {
        case let .loginButtonClicked(oauthtype):
            return ["oauthtype": oauthtype.trackingName]
        }
    }
}

