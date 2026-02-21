//
//  WorkPlaceEditViewModel.swift
//  Moa
//
//  Created by mirim on 2/22/26.
//

import Foundation

final class WorkPlaceEditViewModel {
    
    // MARK: - Dependencies
    
    private let settingUsecase: SettingUsecase
    private(set) var currentWorkplace: String?
    
    init(
        settingUsecase: SettingUsecase,
        currentWorkplace: String?
    ) {
        self.settingUsecase = settingUsecase
        self.currentWorkplace = currentWorkplace
    }
    
    // - MARK: Actions
    
    func updateWorkplace(to workplace: String) async throws {
        try await settingUsecase.updateWorkplace(to: workplace)
    }
}
