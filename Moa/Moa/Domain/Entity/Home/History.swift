//
//  History.swift
//  Moa
//
//  Created by 정도현 on 2/22/26.
//

import Foundation

struct History {
    let date: String
    let type: WorkType
}

enum WorkType: String {
    case work = "WORK"
    case none = "NONE"
}
