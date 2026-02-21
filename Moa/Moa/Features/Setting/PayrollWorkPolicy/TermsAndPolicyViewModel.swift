//
//  TermsAndPolicyViewModel.swift
//  Moa
//
//  Created by mirim on 2/22/26.
//

import Foundation

enum TermsAndPolicyOutput {
    case termsAndPolicyFetched
}

final class TermsAndPolicyViewModel: BaseViewModel<TermsAndPolicyOutput> {
    
    // MARK: - Properties
    
    private(set) var terms: [TermsEntity] = []
    
    // MARK: - Dependencies
    
    private let settingUsecase: SettingUsecase
    
    // MARK: - Init
    
    init(settingUsecase: SettingUsecase) {
        self.settingUsecase = settingUsecase
    }
    
    // MARK: - Actions
    
    func getTermsAndPolicy() {
        Task { @MainActor in
            do {
                let terms = try await settingUsecase.getTerms()
                self.terms = terms
                
                self.send(.termsAndPolicyFetched)
            } catch {
                
            }
        }
    }
    
    func urlString(for code: String) -> String {
        guard let term = terms.first(where: { $0.code == code }) else { return "" }
        return term.contentUrl ?? ""
    }
}
