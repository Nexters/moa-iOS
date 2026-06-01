//
//  Analytics.swift
//  Moa
//
//  Created by mirim on 5/3/26.
//

import Foundation
import PostHog

enum Analytics {
    static func track(_ event: AnalyticsEvent) {
        #if DEBUG
        print("📈 [Analytics]\n- name: \(event.name)\n- properties: \(event.properties)")
        #endif
        
        PostHogSDK.shared.capture(event.name, properties: event.properties)
    }
    
    static func identify(userId: String) {
        #if DEBUG
        print("📈 [Analytics]\n- identify: \(userId)")
        #endif
        
        PostHogSDK.shared.identify(userId)
    }

    static func setPersonProperties(_ userProperty: AnalyticsUserProperty) {
        #if DEBUG
        print("📈 [Analytics]\n- setPersonProperties: \(userProperty)")
        #endif

        PostHogSDK.shared.setPersonProperties(userPropertiesToSet: userProperty.properties)
    }
}
