//
//  WorkingHoursBottomSheetViewModel.swift
//  Moa
//
//  Created by mirim on 2/18/26.
//

import Foundation

enum WorkingTimeSelection {
    case clockIn
    case clockOut
    
    var title: String {
        switch self {
        case .clockIn: "출근"
        case .clockOut: "퇴근"
        }
    }
}

final class WorkingHoursBottomSheetViewModel {
    var onSelectionChanged: (() -> Void)?
    
    private(set) var clockInTime: String
    private(set) var clockOutTime: String
    private(set) var selected: WorkingTimeSelection = .clockIn {
        didSet { onSelectionChanged?() }
    }
    
    init(clockInTime: String, clockOutTime: String) {
        self.clockInTime = clockInTime
        self.clockOutTime = clockOutTime
    }
    
    func selectClockIn() {
        selected = .clockIn
    }
    
    func selectClockOut() {
        selected = .clockOut
    }
    
    func updateClockInTime(_ time: String) {
        clockInTime = time
    }
    
    func updateClockOutTime(_ time: String) {
        clockOutTime = time
    }
}
