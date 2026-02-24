//
//  NotificationSettingViewController.swift
//  Moa
//
//  Created by mirim on 2/22/26.
//

import UIKit
import SnapKit

final class NotificationSettingViewController: BaseViewController {
    
    // MARK: - Constants
    
    enum Constant {
        static let notiSetting = "알림 설정"
    }
    
    // MARK: - Dependencies
    
    private let viewModel: NotificationSettingViewModel
    
    // MARK: - UI Components
    
    private let systemBannerView = SystemNotificationBannerView()
    
    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [systemBannerView])
        stack.axis = .vertical
        stack.spacing = 24
        return stack
    }()
    
    // MARK: - Init
    
    init(viewModel: NotificationSettingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkSystemNotification()
    }
    
    // MARK: - Setup
    
    override func setupUI() {
        replaceSystemBackButtonWithAppBackButton()
        setupNavigationTitle(as: Constant.notiSetting)
        
        view.addSubview(contentStack)
        contentStack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
        }
        
        systemBannerView.isHidden = true
        systemBannerView.onSettingButtonTapped = { [weak self] in
            self?.viewModel.openSystemSettings()
        }
        
        bindViewModel()
        viewModel.getNotificationSettings()
    }
    
    // MARK: - Bind
    
    private func bindViewModel() {
        viewModel.onSectionsLoaded = { [weak self] in
            self?.applySnapshot()
        }
        
        viewModel.onItemUpdated = { [weak self] entity in
            self?.updateToggleView(for: entity)
            if let message = self?.viewModel.toastMessage(for: entity) {
                ToastManager.show(message: message)
            }
        }
        
        viewModel.onError = { [weak self] _ in
            ToastManager.show(message: "알림 설정에 실패했습니다.")
        }
    }
    
    // MARK: - Snapshot
    
    private func applySnapshot() {
        // 기존 섹션 제거 (systemBannerView는 유지)
        contentStack.arrangedSubviews
            .filter { $0 !== systemBannerView }
            .forEach {
                contentStack.removeArrangedSubview($0)
                $0.removeFromSuperview()
            }
        
        viewModel.sections.forEach { section in
            let sectionView = makeSectionView(section: section)
            contentStack.addArrangedSubview(sectionView)
        }
        
        updateUIForSystemNotification(isEnabled: viewModel.isSystemNotificationEnabled)
    }
    
    private func makeSectionView(section: NotificationSection) -> UIStackView {
        let headerLabel = makeSectionHeaderLabel(title: section.category)
        
        let itemStack = UIStackView()
        itemStack.axis = .vertical
        itemStack.spacing = 10
        
        section.items.forEach { item in
            let toggleView = NotificationToggleItemView(title: item.title)
            toggleView.tag = item.type.hashValue
            toggleView.isOn = item.checked
            toggleView.onToggleChanged = { [weak self] isOn in
                self?.handleToggle(type: item.type, isOn: isOn, view: toggleView)
            }
            itemStack.addArrangedSubview(toggleView)
        }
        
        let sectionStack = UIStackView(arrangedSubviews: [headerLabel, itemStack])
        sectionStack.axis = .vertical
        sectionStack.spacing = 8
        return sectionStack
    }
    
    // MARK: - Toggle Handler
    
    private func handleToggle(type: NotificationSettingType, isOn: Bool, view: NotificationToggleItemView) {
        // 낙관적 업데이트 없이 응답 올 때까지 토글 비활성화
        view.isEnabled = false
        viewModel.updateNotificationSetting(type: type, checked: isOn)
    }
    
    private func updateToggleView(for entity: NotificationSettingEntity) {
        allToggleViews()
            .first(where: { $0.tag == entity.type.hashValue })
            .map {
                $0.isOn = entity.checked
                $0.isEnabled = viewModel.isSystemNotificationEnabled
            }
    }
    
    // MARK: - System Notification Check
    
    private func checkSystemNotification() {
        viewModel.checkSystemNotificationStatus { [weak self] isEnabled in
            self?.updateUIForSystemNotification(isEnabled: isEnabled)
        }
    }
    
    private func updateUIForSystemNotification(isEnabled: Bool) {
        systemBannerView.isHidden = isEnabled
        
        contentStack.arrangedSubviews
            .filter { $0 !== systemBannerView }
            .forEach { sectionView in
                (sectionView as? UIStackView)?.arrangedSubviews
                    .compactMap { $0 as? UIStackView }
                    .flatMap { $0.arrangedSubviews }
                    .compactMap { $0 as? NotificationToggleItemView }
                    .forEach { $0.isEnabled = isEnabled }
            }
    }
    
    // MARK: - Factory
    
    private func makeSectionHeaderLabel(title: String) -> StyledLabel {
        let label = StyledLabel()
        label.setText(
            title,
            style: .init(
                typography: AppTypography.b2_500,
                color: AppColor.IconAndText.mediumEmphasis
            )
        )
        return label
    }
    
    private func allToggleViews() -> [NotificationToggleItemView] {
        contentStack.arrangedSubviews
            .filter { $0 !== systemBannerView }
            .compactMap { $0 as? UIStackView }
            .flatMap { $0.arrangedSubviews }
            .compactMap { $0 as? UIStackView }
            .flatMap { $0.arrangedSubviews }
            .compactMap { $0 as? NotificationToggleItemView }
    }
}
