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
        static let selectPayday = "월급일을 선택해주세요"
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
    
    private let paydayBottomSheetButton: UIButton = {
        let btn = UIButton()
        btn.setTitle(Constants.payday, for: .normal)
        
        return btn
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        // TODO: StackView만들기
        return stack
    }()
    
    override func setupUI() {
        setupNavigationTitle(as: Constants.payday)
        replaceSystemBackButtonWithAppBackButton()
        stackView.addArrangedSubViews([whenIsPaydayLabel, paydayLabel])
    }
    
    private func showPaydaySelectionBottomSheet() {
        // TODO: 바텀시트 뷰컨 만들기
        // TODO: TimeWheelColumnView 사용해서 월급일 피커 구현
    }
    
    // MARK: - Init
    
    init(viewModel: PaydayEditViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
