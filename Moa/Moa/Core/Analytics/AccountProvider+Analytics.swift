//
//  AccountProvider+Analytics.swift
//  Moa
//
//  Created by mirim on 5/3/26.
//

import Foundation

extension AccountProvider {
    var trackingName: String {
        switch self {
        case .kakao: "KAKAO"
        case .apple: "APPLE"
        }
    }
}
