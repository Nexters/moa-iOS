//
//  SocialLoginRequest.swift
//  Moa
//
//  Created by mirim on 2/10/26.
//

import Foundation

struct SocialLoginRequest: Encodable {
    let idToken: String
    let fcmDeviceToken: String?
}
