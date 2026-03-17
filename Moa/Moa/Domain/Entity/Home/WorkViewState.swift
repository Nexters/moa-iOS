//
//  WorkViewState.swift
//  Moa
//
//  Created by 정도현 on 3/17/26.
//

import Foundation

enum WorkViewState: Equatable {
    case idle
    case loading
    case loaded(status: WorkStatusEntity, data: HomeEntity)
    case error(WorkViewError)
}
