//
//  SettingHomeViewModel.swift
//  Moa
//
//  Created by mirim on 2/19/26.
//

import Foundation

final class SettingHomeViewModel {
    
    // MARK: - Dependencies
    
    // usecase
    
    // MARK: - State
    
    private(set) var accountProvider: AccountProvider = .kakao
    private(set) var nickname: String = "집계사장"
    
    
    // MARK: - Init
    
    // MARK: - Actions
    
    func getMemberInfo() async throws {
        // usecase로 api 호출하기
    }
}
