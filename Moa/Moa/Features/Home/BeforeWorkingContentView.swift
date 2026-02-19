//
//  BeforeWorkingContentView.swift
//  Moa
//
//  Created by 정도현 on 2/18/26.
//

import UIKit
import Combine
import SnapKit

protocol BeforeWorkingViewDelegate: AnyObject {
    func beforeWorkingViewDidTapStartWork(_ view: BeforeWorkingContentView)
    func beforeWorkingViewDidTapVacation(_ view: BeforeWorkingContentView)
    func beforeWorkingViewDidRequestTimeSelection(_ view: BeforeWorkingContentView)
}

final class BeforeWorkingContentView: UIView {
    
    // MARK: - Constants
    
    private enum Constant {
        static let earlyWork = "일찍 출근하기"
        static let todayVacation = "오늘 휴가예요"
    }
    
    // MARK: - Delegate
    weak var delegate: BeforeWorkingViewDelegate?
    
    // MARK: - UI Components
    private let contentViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.Background.primary
        return view
    }()
    
    private lazy var dateLocationInfoView: DateLocationInfoView = {
        DateLocationInfoView(date: getCurrentDateString(), location: "")
    }()
    
    private lazy var monthlySalaryView = MonthlySalaryView(
        month: 2,
        amount: 0,
        baseAmount: 0,
        shouldAnimate: false
    )
    
    private lazy var todayWorkSummaryView: TodayWorkSummaryView = {
        let view = TodayWorkSummaryView()
        view.onTapTimeRow = { [weak self] in
            guard let self else { return }
            
            self.delegate?.beforeWorkingViewDidRequestTimeSelection(self)
        }
        return view
    }()
    
    // Bottom Action Group
    private let bottomActionContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.Background.primary
        return view
    }()
    
    private lazy var autoWorkIndicator = SpeechBubble()
    
    private lazy var startWorkButton: AppButton = {
        let button = AppButton()
        button.setTitle(Constant.earlyWork, for: .normal)
        button.applyStyle(.primary())
        button.addTarget(self, action: #selector(didTapMainButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var underlineButton: UnderlineTextButton = {
        let button = UnderlineTextButton(title: Constant.todayVacation)
        button.addTarget(self, action: #selector(didTapVacation), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Lifecycle
    
    func setupUI() {
        self.backgroundColor = AppColor.Background.primary
        setupHierarchy()
        setupConstraints()
    }
    
    func configure(
        monthlyInfo: MonthlyInfo,
        workTime: WorkTime,
        wage: Int
    ) {
//        monthlySalaryView.updateAmount(
//            month: monthlyInfo.month,
//            amount: monthlyInfo.currentAmount,
//            baseAmount: monthlyInfo.baseAmount,
//            animated: true
//        )
        
        autoWorkIndicator.configure(text: "\(workTime.start.displayString) 자동 출근 예정")
        
        todayWorkSummaryView.configure(
            wage: wage,
            startTime: workTime.start.displayString,
            endTime: workTime.end.displayString
        )
    }

}

// MARK: - Layout

private extension BeforeWorkingContentView {
    
    func setupHierarchy() {
        self.addSubViews([
            contentViewContainer,
            bottomActionContainerView
        ])
        
        // 메인 컨텐츠
        contentViewContainer.addSubViews([
            dateLocationInfoView,
            monthlySalaryView,
            todayWorkSummaryView
        ])
        
        // 하단 바텀 버튼
        bottomActionContainerView.addSubViews([
            autoWorkIndicator,
            startWorkButton,
            underlineButton
        ])
    }
    
    func setupConstraints() {
        
        // 근무 전 View
        contentViewContainer.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview()
        }
        
        dateLocationInfoView.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
        }
        
        monthlySalaryView.snp.makeConstraints {
            $0.top.equalTo(dateLocationInfoView.snp.bottom).offset(28)
            $0.centerX.equalToSuperview()
        }
        
        todayWorkSummaryView.snp.makeConstraints {
            $0.top.equalTo(monthlySalaryView.snp.bottom).offset(36)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        // Bottom Action Group
        bottomActionContainerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        autoWorkIndicator.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        startWorkButton.snp.makeConstraints {
            $0.top.equalTo(autoWorkIndicator.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
        }
        
        underlineButton.snp.makeConstraints {
            $0.top.equalTo(startWorkButton.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(24)
        }
    }
}

// MARK: - Actions

private extension BeforeWorkingContentView {
    
    @objc
    func didTapMainButton() {
        delegate?.beforeWorkingViewDidTapStartWork(self)
    }
    
    @objc
    func didTapVacation() {
        delegate?.beforeWorkingViewDidTapVacation(self)
    }
}


// MARK: - Helpers

private extension BeforeWorkingContentView {
    
    func getCurrentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 EEEE"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: Date())
    }
}
