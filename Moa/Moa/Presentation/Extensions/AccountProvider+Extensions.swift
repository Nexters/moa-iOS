//
//  AccountProvider+Extensions.swift
//  Moa
//
//  Created by mirim on 2/19/26.
//

import Foundation

extension AccountProvider {
    var displayName: String {
        switch self {
        case .kakao: "카카오 계정 회원"
        case .apple: "애플 계정 회원"
        }
    }
    
    var displayDescription: String {
        switch self {
        case .kakao: "카카오 계정으로 가입"
        case .apple: "애플 계정으로 가입"
        }
    }
}
