//
//  WorkAlarmBottomSheet.swift
//  Moa
//
//  Created by 정도현 on 2/10/26.
//

import UIKit
import SnapKit

// MARK: - Simple Test Bottom Sheet Delegate
protocol WorkAlarmBottomSheetDelegate: AnyObject {
    func didTapAlarm()
    func didTapLater()
}

final class WorkAlarmBottomSheet: UIViewController, BottomSheetPresentable {
    
    // MARK: - Properties
    weak var delegate: WorkAlarmBottomSheetDelegate?
    
    // MARK: - UI
    
    private let titleLabel: UILabel = {
        let label = StyledLabel()
        label.setText(
            "근무 알림을 받아보세요!",
            style: .init(
                typography: AppTypography.t1_700,
                color: AppColor.IconAndText.highEmphasis
            )
        )
        
        label.numberOfLines = 1
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = StyledLabel()
        label.text = """
        알림 수신에 동의하면, 출퇴근 시간과 월급일에
        알림을 보내드릴게요!
        """
        label.setStyle(
            .init(
                typography: AppTypography.b1_400,
                color: AppColor.IconAndText.highEmphasis
            )
        )
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var notificationControlBtn: AppButton = {
        let button = AppButton()
        button.setTitle("알림 받을게요", for: .normal)
        button.applyStyle(.primary())
        button.addTarget(
            self,
            action: #selector(didTapAlarmButton),
            for: .touchUpInside
        )
        
        return button
    }()
    
    private lazy var dismissBtn: UnderlineTextButton = {
        let button = UnderlineTextButton(title: "다음에 할게요")
        button.addTarget(
            self,
            action: #selector(didTapLaterButton),
            for: .touchUpInside
        )
        
        return button
    }()
    
    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.spacing = 16
        return stack
    }()
    
    private let btnStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.spacing = 16
        return stack
    }()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        view.backgroundColor = AppColor.Container.primary
        
        view.addSubview(contentStackView)
        view.addSubview(btnStackView)
        
        contentStackView.addArrangedSubViews([titleLabel, descriptionLabel])
        btnStackView.addArrangedSubViews([notificationControlBtn, dismissBtn])
        
        contentStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
        }
        
        btnStackView.snp.makeConstraints { make in
            make.top.equalTo(contentStackView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
            make.bottom.equalToSuperview().offset(-24)
        }
    }
    
    
    @objc private func didTapAlarmButton() {
        delegate?.didTapAlarm()
        dismissBottomSheet()
    }
    
    @objc private func didTapLaterButton() {
        delegate?.didTapLater()
        dismissBottomSheet()
    }
    
    private func dismissBottomSheet() {
        (parent as? BottomSheetViewController)?.animateDismiss()
    }
}
