//
//  WorkingHoursBottomSheetViewController.swift
//  Moa
//
//  Created by mirim on 2/18/26.
//

import UIKit
import SnapKit

protocol WorkingHoursBottomSheetViewDelegate: AnyObject {
    func didTapConfirm(clockInTime: String, clockOutTime: String)
}

final class WorkingHoursBottomSheetViewController: UIViewController, BottomSheetPresentable {
    
    // MARK: - Constants
    
    private enum Constant {
        static let workingHoursTitle = "근무 시간을 알려주세요"
        static let confirm = "확인"
    }
    
    // MARK: - Properties
    
    weak var delegate: WorkingHoursBottomSheetViewDelegate?
    private let viewModel: WorkingHoursBottomSheetViewModel
    
    // MARK: - UI
    
    private lazy var titleLabel: StyledLabel = {
        let label = StyledLabel()
        label.setText(
            Constant.workingHoursTitle,
            style: .init(
                typography: AppTypography.t1_700,
                color: AppColor.IconAndText.highEmphasis
            )
        )
        label.textAlignment = .left
        return label
    }()
    
    private lazy var clockInLabel: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.alignment = .center
        
        let label = StyledLabel()
        label.setText(
            WorkingTimeSelection.clockIn.title,
            style: .init(typography: AppTypography.b2_500, color: AppColor.IconAndText.lowEmphasis)
        )
        
        stack.addArrangedSubViews([label, clockInButton])
        
        return stack
    }()
    
    private lazy var clockInButton: UIButton = {
        let btn = UIButton()
        btn.setTitle(
            viewModel.clockInTime,
            for: .normal
        )
        btn.addTarget(self, action: #selector(didTapClockIn), for: .touchUpInside)
        
        return btn
    }()
    
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .Icon.iconArrowRight)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var clockOutLabel: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.alignment = .center
        
        let label = StyledLabel()
        label.setText(
            WorkingTimeSelection.clockOut.title,
            style: .init(typography: AppTypography.b2_500, color: AppColor.IconAndText.lowEmphasis)
        )
        
        stack.addArrangedSubViews([label, clockOutButton])
        
        return stack
    }()
    
    private lazy var clockOutButton: UIButton = {
        let btn = UIButton()
        btn.setTitle(
            viewModel.clockOutTime,
            for: .normal
        )
        
        btn.addTarget(self, action: #selector(didTapClockOut), for: .touchUpInside)
        
        return btn
    }()
    
    private lazy var workHoursHStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 20
        stack.alignment = .center
        stack.distribution = .fillEqually
        return stack
    }()
    
    // MARK: - Init
    
    init(viewModel: WorkingHoursBottomSheetViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        viewModel.onSelectionChanged = { [weak self] in
            self?.updateUIOnSelection()
        }
        
        updateUIOnSelection()
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        view.addSubViews([titleLabel, workHoursHStack])
        workHoursHStack.addArrangedSubViews([clockInLabel, arrowImageView, clockOutLabel])
        
        arrowImageView.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
        }
        
        workHoursHStack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(35)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapClockIn() {
        viewModel.selectClockIn()
    }
    
    @objc private func didTapClockOut() {
        viewModel.selectClockOut()
    }
    
    private func updateUIOnSelection() {
        let isClockInSelected = viewModel.selected == .clockIn
        let isClockOutSelected = viewModel.selected == .clockOut

        // clock in
        clockInButton.setTitleColor(
            isClockInSelected ? AppColor.IconAndText.green : AppColor.IconAndText.lowEmphasis,
            for: .normal
        )
        clockInButton.titleLabel?.font = isClockInSelected ? AppTypography.t1_700.font() : AppTypography.t1_500.font()

        // clock out
        clockOutButton.setTitleColor(
            isClockOutSelected ? AppColor.IconAndText.green : AppColor.IconAndText.lowEmphasis,
            for: .normal
        )
        clockOutButton.titleLabel?.font = isClockOutSelected ? AppTypography.t1_700.font() : AppTypography.t1_500.font()
    }
}
