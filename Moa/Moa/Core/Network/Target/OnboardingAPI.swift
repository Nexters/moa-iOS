//
//  OnboardingAPI.swift
//  Moa
//
//  Created by mirim on 2/16/26.
//

import Foundation
import Moya
import Alamofire

enum OnboardingAPI {
    case getOnboardingStatus // 상태 조회
    case getOnboardingTerms // 약관 항목 목록 조회
    case updateOnboardingProfile(OnboardingProfileUpsertRequest) // 프로필 정보 갱신
    case updateOnboardingPayroll // 급여 정보 갱신
    case updateOnboardingWorkpolicy // 근무조건 정보 갱신
    case getTermsAgreementStatus // 약관 동의 현황 조회
    case updateTermsAgreementStatus // 약관 동의 여부 갱신
}

extension OnboardingAPI: TargetType {
    
    var baseURL: URL {
        URL(string: "http://139.150.10.57:8080")!
    }
    
    var path: String {
        switch self {
        case .getOnboardingStatus:
            "/api/v1/onboarding/status"
        case .getOnboardingTerms:
            "/api/v1/onboarding/terms"
        case .updateOnboardingProfile:
            "/api/v1/onboarding/profile"
        case .updateOnboardingPayroll:
            "/api/v1/onboarding/payroll"
        case .updateOnboardingWorkpolicy:
            "/api/v1/onboarding/work-policy"
        case .getTermsAgreementStatus:
            "/api/v1/onboarding/terms/agreements"
        case .updateTermsAgreementStatus:
            "/api/v1/onboarding/terms/agreements"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getOnboardingStatus:
            return .get
        case .getOnboardingTerms:
            return .get
        case .updateOnboardingProfile:
            return .patch
        case .updateOnboardingPayroll:
            return .patch
        case .updateOnboardingWorkpolicy:
            return .patch
        case .getTermsAgreementStatus:
            return .get
        case .updateTermsAgreementStatus:
            return .put
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getOnboardingStatus:
            return .requestPlain
        case .getOnboardingTerms:
            return .requestPlain
        case let .updateOnboardingProfile(body):
            return .requestJSONEncodable(body)
        case .updateOnboardingPayroll:
            return .requestPlain
        case .updateOnboardingWorkpolicy:
            return .requestPlain
        case .getTermsAgreementStatus:
            return .requestPlain
        case .updateTermsAgreementStatus:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        nil
    }
}
