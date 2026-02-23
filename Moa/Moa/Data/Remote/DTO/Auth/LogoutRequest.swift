//
//  LogoutRequest.swift
//  Moa
//
//  Created by mirim on 2/24/26.
//

import Foundation

struct LogoutRequest: Encodable {
    let fcmDeviceToken: String
}
