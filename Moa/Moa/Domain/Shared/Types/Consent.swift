//
//  Consent.swift
//  Moa
//
//  Created by mirim on 2/14/26.
//

import Foundation

/// 약관 동의 항목
enum Consent: CustomStringConvertible {
    case usageTerm
    case personalInfo
    case marketing
    
    var description: String {
        switch self {
        case .usageTerm: "이용약관 동의"
        case .personalInfo: "개인정보 수집 및 이용 동의"
        case .marketing: "마케팅 활용 및 정보 수신 동의"
        }
    }
    
    /// 필수 동의 여부
    var isRequired: Bool {
        switch self {
        case .usageTerm: true
        case .personalInfo: true
        case .marketing: false
        }
    }
}
