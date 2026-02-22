//
//  HomeRepository.swift
//  Moa
//
//  Created by 정도현 on 2/22/26.
//

import Foundation

protocol HomeRepository {
    func fetchData() async throws -> HomeEntity
}
