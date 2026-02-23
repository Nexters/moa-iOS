//
//  NotificationSettingViewModel.swift
//  Moa
//
//  Created by mirim on 2/22/26.
//

import Foundation
import UIKit

final class NotificationSettingViewModel {
    
    // MARK: - Dependencies
    
    private let settingUsecase: SettingUsecase
    
    // MARK: - Properties
        
    private(set) var isSystemNotificationEnabled: Bool = false
    private(set) var isMarketingAgreed: Bool = false
    
    private(set) var sections: [NotificationSection] = []
    var onSectionsLoaded: (() -> Void)?
    var onItemUpdated: ((NotificationSettingEntity) -> Void)?
    var onError: ((Error) -> Void)?
    
    // type → checked 상태 관리
    private var checkedState: [NotificationSettingType: Bool] = [:]
    
    init(settingUsecase: SettingUsecase) {
        self.settingUsecase = settingUsecase
    }
    
    func isOn(for type: NotificationSettingType) -> Bool {
        checkedState[type] ?? false
    }
    
    func checkSystemNotificationStatus(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isSystemNotificationEnabled = settings.authorizationStatus == .authorized
                completion(self.isSystemNotificationEnabled)
            }
        }
    }
    
    func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
    
    // MARK: - Helpers
    
    func toastMessage(for entity: NotificationSettingEntity) -> String? {
        let date = formattedToday()
        switch entity.type {
        case .work: return "\(date) 출퇴근 알림을 \(entity.checked ? "켰어요" : "껐어요")."
        case .payday: return "\(date) 월급날 알림을 \(entity.checked ? "켰어요" : "껐어요")."
        case .marketing: return entity.checked ? "\(date) 마케팅 수신 동의 완료\n혜택 및 이벤트 알림을 켰어요." : "\(date) 마케팅 정보 수신 동의 철회\n혜택 및 이벤트 알림을 껐어요."
        }
    }
    
    private func formattedToday() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: Date())
    }
    
    func getNotificationSettings() {
        Task { @MainActor in
            do {
                let items = try await settingUsecase.getNotificationSettings()
                
                // checked 상태 저장
                items.forEach { checkedState[$0.type] = $0.checked }
                
                // MARKETING 타입이 있으면 마케팅 동의 상태 반영
                isMarketingAgreed = checkedState[.marketing] ?? false
                
                // category 기준으로 섹션 그루핑 (순서 보장을 위해 NSOrderedSet 패턴 사용)
                var categoryOrder: [String] = []
                var grouped: [String: [NotificationSettingEntity]] = [:]
                items.forEach { item in
                    if grouped[item.category] == nil {
                        categoryOrder.append(item.category)
                    }
                    grouped[item.category, default: []].append(item)
                }
                
                sections = categoryOrder.compactMap { category in
                    guard let items = grouped[category] else { return nil }
                    return NotificationSection(category: category, items: items)
                }
                
                onSectionsLoaded?()
            } catch {
                onError?(error)
            }
        }
    }
    
    func updateNotificationSetting(type: NotificationSettingType, checked: Bool) {
        Task { @MainActor in
            do {
                let updatedItem = try await settingUsecase.updateNotificationSettings(
                    type: type.rawValue,
                    checked: checked
                )
                guard let updatedEntity = updatedItem.first(where: { $0.type == type }) else { return }

                sections = sections.map { section in
                    let updatedItems = section.items.map { item in
                        item.type == updatedEntity.type ? updatedEntity : item
                    }
                    return NotificationSection(category: section.category, items: updatedItems)
                }

                if updatedEntity.type == .marketing {
                    isMarketingAgreed = updatedEntity.checked
                }

                onItemUpdated?(updatedEntity)
            } catch {
                onError?(error)
            }
        }
    }
}
