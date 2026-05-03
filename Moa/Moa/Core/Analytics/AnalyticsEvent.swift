//
//  AnalyticsEvent.swift
//  Moa
//
//  Created by mirim on 5/3/26.
//

import Foundation

/// 사용자 행동 이벤트 - Analytics.track(:)으로 전송
enum AnalyticsEvent {
    /// 로그인 성공 후 화면 이동
    case loginButtonClicked(oauthtype: AccountProvider)
    /// 닉네임 변경 성공 후 화면 이동
    case nicknameNextClicked(isModified: Bool)
    /// 급여 정보 변경 성공 후 화면 이동
    case salaryNextClicked(isModified: Bool)
    /// 근무 정보 변경 성공 후 화면 이동
    case workPolicyNextClicked(isModified: Bool)
    /// 이용약관 동의 성공 후 화면 이동
    case workPolicyTermsNextClicked
    /// 위젯 추가 버튼 클릭
    case widgetAddClicked // TODO
    /// 지금 출근하기 버튼 클릭
    case beforeWorkNowWorkClicked
    /// 근무시간 row 눌러서 일정 변경 화면 이동
    case beforeWorkWorkTimeClicked
    
    var name: String {
        switch self {
        case .loginButtonClicked: "login_button_clicked"
        case .nicknameNextClicked: "nickname_next_clicked"
        case .salaryNextClicked: "salary_next_clicked"
        case .workPolicyNextClicked: "work_policy_next_clicked"
        case .workPolicyTermsNextClicked: "work_policy_terms_next_clicked"
        case .widgetAddClicked: "widget_add_clicked"
        case .beforeWorkNowWorkClicked: "before_work_now_work_clicked"
        case .beforeWorkWorkTimeClicked: "before_work_work_time_clicked"
        
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
        case .workPolicyTermsNextClicked:
            return [:]
        case .widgetAddClicked:
            return [:]
        case .beforeWorkNowWorkClicked:
            return [:]
        case .beforeWorkWorkTimeClicked:
            return [:]
        }
    }
}

