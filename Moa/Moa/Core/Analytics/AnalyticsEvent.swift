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
    /// 홈(근무전) - 지금 출근하기 버튼 클릭
    case beforeWorkNowWorkClicked
    /// 홈(근무전) - 근무시간 row 클릭
    case beforeWorkWorkTimeClicked
    /// 근무중 화면 체류 시간 (초 단위)
    case workingScreenTime(seconds: Int)
    /// 홈(근무중) - 근무시간 row 클릭
    case workingWorkTimeClicked
    /// 홈(근무중) - 더일할게요 버튼 클릭
    case workingMoreWorkClicked
    /// 홈(근무중) - 완료 버튼 클릭
    case workingWorkCompletedClicked
    /// 캘린더 상단 수정 버튼 클릭
    case calendarEditClicked
    /// 캘린더 하단 리스트 클릭 (월급 아이템 제외)
    case calendarListClicked
    
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
        case .workingScreenTime: "working_screen_time"
        case .workingWorkTimeClicked: "working_work_time_clicked"
        case .workingMoreWorkClicked: "working_more_work_clicked"
        case .workingWorkCompletedClicked: "working_work_completed_clicked"
        case .calendarEditClicked: "calendar_edit_clicked"
        case .calendarListClicked: "calendar_list_clicked"
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
        case let .workingScreenTime(seconds):
            return ["time": seconds]
        case .workingWorkTimeClicked:
            return [:]
        case .workingMoreWorkClicked:
            return [:]
        case .workingWorkCompletedClicked:
            return [:]
        case .calendarEditClicked:
            return [:]
        case .calendarListClicked:
            return [:]
        }
    }
}

