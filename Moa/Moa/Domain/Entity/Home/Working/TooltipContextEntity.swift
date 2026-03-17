//
//  TooltipContextEntity.swift
//  Moa
//
//  Created by 정도현 on 3/17/26.
//

import Foundation

struct TooltipContextEntity {
    let workingType: WorkingType
    let workedEarnings: Int            // 이번달 누적 월급
    let endTime: TimeIndicatorEntity   // 오늘 퇴근 시간
}
