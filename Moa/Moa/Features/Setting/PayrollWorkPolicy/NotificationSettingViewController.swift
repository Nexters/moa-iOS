//
//  NotificationSettingViewController.swift
//  Moa
//
//  Created by mirim on 2/22/26.
//

import UIKit
import SnapKit

final class NotificationSettingViewController: BaseViewController {
    
    // MARK: - Constants
    
    enum Constant {
        static let notiSetting = "알림 설정"
        static let turnOnOsNotiMessage = "OS 설정에서 알림을 켜주세요.\n출퇴근 시간에 푸시 알림을 보내드릴게요."
        static let serviceNoti = "서비스 알림"
        static let commuteNoti = "출퇴근 알림"
        static let paydayNoti = "월급날 알림"
    }
    
    // MARK: - UI Components
    
    private let turnOnOsNotification: UIButton = {
        let btn = UIButton()
        return btn
    }()
}
