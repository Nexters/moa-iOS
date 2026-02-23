//
//  PaydayEditViewController.swift
//  Moa
//
//  Created by mirim on 2/22/26.
//

import UIKit
import SnapKit

final class PaydayEditViewController: BaseViewController {
    
    // MARK: - Constants
    
    enum Constants {
        static let whenIsPayday = "언제 월급을 받나요?"
        static let payday = "월급일"
        static let complete = "완료"
        static let confirm = "확인"
    }
    
    // MARK: - Dependencies
    
    private let viewModel: PaydayEditViewModel
    
    // MARK: - UI Components
    
    private let whenIsPaydayLabel: StyledLabel = {
        let label = StyledLabel()
        label.setText(
            Constants.whenIsPayday,
            style: .init(
                typography: AppTypography.t1_700,
                color: AppColor.IconAndText.highEmphasis
            )
        )
        return label
    }()
    
    private let paydayLabel: StyledLabel = {
        let label = StyledLabel()
        label.setText(
            Constants.payday,
            style: .init(
                typography: AppTypography.b2_500,
                color: AppColor.IconAndText.mediumEmphasis
            )
        )
        return label
    }()
    
    private let paydayBottomSheetButtonLabel: StyledLabel = {
        let label = StyledLabel()
        label.setStyle(.init(
            typography: AppTypography.t2_700,
            color: AppColor.IconAndText.highEmphasis
        ))
        return label
    }()
    
    private let spacerView: UIView = {
        let view = UIView()
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return view
    }()
    
    private let arrowDownIconView: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(resource: .Icon.iconArrowDown)
        
        let button = UIButton(configuration: config)
        button.isUserInteractionEnabled = false // 스택뷰 제스처가 받도록
        return button
    }()
    
    private lazy var paydayPickerButton: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [paydayBottomSheetButtonLabel, spacerView, arrowDownIconView])
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.isUserInteractionEnabled = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        stack.backgroundColor = AppColor.Container.primary
        stack.layer.cornerRadius = 12
        return stack
    }()
    
    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .leading
        return stack
    }()
    
    private let completeButton: AppButton = {
        let btn = AppButton()
        btn.setTitle(Constants.complete, for: .normal)
        btn.applyStyle(.primary())
        return btn
    }()
    
    // MARK: - Init
    
    init(viewModel: PaydayEditViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    override func setupUI() {
        setupGesture()
        view.addSubViews([contentStackView, completeButton])
        setupNavigationTitle(as: Constants.payday)
        replaceSystemBackButtonWithAppBackButton()
        paydayBottomSheetButtonLabel.setText("\(viewModel.selectedPayday)일")
        
        contentStackView.addArrangedSubViews([whenIsPaydayLabel, paydayLabel, paydayPickerButton])
        contentStackView.setCustomSpacing(32, after: whenIsPaydayLabel)
        contentStackView.setCustomSpacing(8, after: paydayLabel)
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        
        paydayPickerButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.greaterThanOrEqualTo(60)
        }
        
        contentStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.screenHorizontal)
            make.bottom.lessThanOrEqualTo(completeButton.snp.top).offset(-AppSpacing.ctaBottom)
        }
        
        completeButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.screenHorizontal)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.ctaBottom)
            make.height.equalTo(64)
        }
    }
    
    private func showPaydaySelectionBottomSheet() {
        let sheet = PaydaySelectionBottomSheet(initialPayday: viewModel.selectedPayday)
        sheet.delegate = self
        presentBottomSheet(sheet)
    }
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(stackButtonTapped))
        paydayPickerButton.addGestureRecognizer(tapGesture)
    }
    
    @objc private func stackButtonTapped() {
        showPaydaySelectionBottomSheet()
    }
    
    @objc private func completeButtonTapped() {
        Task { @MainActor in
            do {
                try await viewModel.updatePayday()
                navigationController?.popViewController(animated: true)
            } catch {
                // TODO: 에러 처리
            }
        }
    }
}

extension PaydayEditViewController: PaydaySelectionBottomSheetDelegate {
    func paydaySelectionBottomSheet(_ sheet: PaydaySelectionBottomSheet, didTapConfirmButton selectedPayday: Int) {
        viewModel.selectedPaydayChanged(to: selectedPayday)
        paydayBottomSheetButtonLabel.setText("\(viewModel.selectedPayday)일")
    }
}
