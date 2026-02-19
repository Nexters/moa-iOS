//
//  AccountProvider+API.swift
//  Moa
//
//  Created by mirim on 2/19/26.
//

import Foundation

extension AccountProvider {
    var apiValue: String {
        switch self {
        case .kakao: return "KAKAO"
        case .apple: return "APPLE"
        }
    }
}
