//
//  FcmRepository.swift
//  Moa
//
//  Created by mirim on 2/24/26.
//

import Foundation

protocol FcmRepository {
    func updateFcmToken(to fcmToken: String) async
    func deleteFcmToken(fcmToken: String) async
}
