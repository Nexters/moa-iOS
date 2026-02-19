//
//  TermsAgreementBottomSheetViewModel.swift
//  Moa
//
//  Created by mirim on 2/15/26.
//

import Foundation

final class TermsAgreementBottomSheetViewModel {
    var onStateChanged: (() -> Void)?

    private(set) var terms: [TermsEntity]
    private var agreedMap: [String: Bool]
    
    var agreementsByCode: [String: Bool] {
        var result: [String: Bool] = [:]
        for term in terms {
            if let code = term.code {
                result[code] = agreedMap[code] ?? false
            }
        }
        return result
    }

    var allRequiredAgreed: Bool {
        terms.filter { $0.required }.allSatisfy { term in
            guard let code = term.code else { return false }
            return agreedMap[code] ?? false
        }
    }

    var allAgreed: Bool {
        terms.allSatisfy { term in
            guard let code = term.code else { return false }
            return agreedMap[code] ?? false
        }
    }
    
    init(terms: [TermsEntity]) {
        self.terms = terms
        var map: [String: Bool] = [:]
        for term in terms {
            if let code = term.code {
                map[code] = false
            }
        }
        self.agreedMap = map
    }

    func setAll() {
        let next = !allAgreed
        for term in terms {
            if let code = term.code { agreedMap[code] = next }
        }
        onStateChanged?()
    }

    func toggle(code: String) {
        guard let current = agreedMap[code] else { return }
        agreedMap[code] = !current
        onStateChanged?()
    }
    
    func agreed(for code: String) -> Bool {
        agreedMap[code] ?? false
    }
    
    func url(for code: String) -> URL? {
        guard let term = terms.first(where: { $0.code == code }),
                let urlString = term.contentUrl
        else { return nil }
        
        return URL(string: urlString)
    }
    
    func urlString(for code: String) -> String {
        guard let term = terms.first(where: { $0.code == code }) else { return "" }
        return term.contentUrl ?? ""
    }
}
