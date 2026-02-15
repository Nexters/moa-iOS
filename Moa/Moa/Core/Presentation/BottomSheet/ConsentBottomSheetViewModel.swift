//
//  ConsentBottomSheetViewModel.swift
//  Moa
//
//  Created by mirim on 2/15/26.
//

import Foundation

final class ConsentBottomSheetViewModel {

    private(set) var usageTermAgreed: Bool
    private(set) var personalInfoAgreed: Bool
    private(set) var marketingAgreed: Bool

    init(
        usageTermAgreed: Bool = false,
        personalInfoAgreed: Bool = false,
        marketingAgreed: Bool = false
    ) {
        self.usageTermAgreed = usageTermAgreed
        self.personalInfoAgreed = personalInfoAgreed
        self.marketingAgreed = marketingAgreed
    }

    var allRequiredAgreed: Bool {
        usageTermAgreed && personalInfoAgreed
    }
    var allAgreed: Bool {
        usageTermAgreed && personalInfoAgreed && marketingAgreed
    }

    func setAll() {
        let next = !allAgreed
        usageTermAgreed = next
        personalInfoAgreed = next
        marketingAgreed = next
    }

    func toggleUsageTerm() {
        usageTermAgreed.toggle()
    }

    func togglePersonalInfo() {
        personalInfoAgreed.toggle()
    }

    func toggleMarketing() {
        marketingAgreed.toggle()
    }
}

