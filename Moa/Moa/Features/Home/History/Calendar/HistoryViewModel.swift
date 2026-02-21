//
//  HistoryViewModel.swift
//  Moa
//
//  Created by 정도현 on 2/22/26.
//

import Foundation

enum HistoryOutput {
    
}

final class HistoryViewModel: BaseViewModel<HistoryOutput> {
    
    // MARK: - Dependencies
    
    private let historyUsecase: HistoryUseCase
    
    // MARK: - State
    
    // MARK: - Init
    
    init(
        historyUsecase: HistoryUseCase
    ) {
        self.historyUsecase = historyUsecase
    }

    // MARK: - Actions
    
   
}
