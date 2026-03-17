//
//  WorkStatusEntity.swift
//  Moa
//
//  Created by 정도현 on 3/17/26.
//

import Foundation

enum WorkStatusEntity: Equatable {
    case idle           // 근무 전 / 공휴일
    case working        // 근무 중
    case workFinished   // 근무완료 1 (EndBottomIndicator 오버레이)
    case finished       // 최종완료 ("완료" 탭 후 WorkMainContentView .finished)

    /// 출근 후 상태 여부 (working + workFinished)
    var isActive: Bool {
        self == .working || self == .workFinished
    }
}
