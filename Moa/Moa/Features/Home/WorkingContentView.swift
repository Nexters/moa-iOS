//
//  WorkingContentView.swift
//  Moa
//
//  Created by 정도현 on 2/18/26.
//

import UIKit
import SnapKit

// MARK: - WorkingContentViewDelegate

enum WorkingType {
    case work
    case vacation
    
    var stackImage: UIImage {
        switch self {
        case .work:
            return UIImage(resource: .Image.imgWorkingMoneyStack)
        case .vacation:
            return UIImage(resource: .Image.imgVacationMoneyStack)
        }
    }
    
    var barColor: UIColor {
        switch self {
        case .work:
            return AppColor.IconAndText.blue
        case .vacation:
            return AppColor.IconAndText.blue
        }
    }
    
    var badgeType: BadgeType {
        switch self {
        case .work:
            return .working
        case .vacation:
            return .vacation
        }
    }
}

protocol WorkingContentViewDelegate: AnyObject {
    func workingContentViewDidTapScheduleAdjust(_ view: WorkingContentView)
}

// MARK: - WorkingContentView

final class WorkingContentView: UIView {

    // MARK: - Delegate

    weak var delegate: WorkingContentViewDelegate?

    // MARK: - UI
    private let workingType: WorkingType

    // 상단: 월급 기둥
    private lazy var earningsStackView = {
        return EarningsStackView(workingType: workingType)
    }()

    // 하단 컨테이너
    private let bottomContainer: UIView = {
        let view = UIView()
        return view
    }()

    // 근무 상태
    private lazy var workingStatusView: WorkingStatusView = {
        let view = WorkingStatusView(workingType: workingType)
        view.delegate = self
        return view
    }()

    // MARK: - Init

    init (workingType: WorkingType) {
        self.workingType = workingType
        super.init(frame: .zero)
        
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        addSubViews([
            earningsStackView,
            bottomContainer
        ])

        bottomContainer.addSubview(workingStatusView)

        // 월급 기둥 (상단에서 하단까지)
        earningsStackView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomContainer.snp.top).offset(40)
        }

        // 하단 컨테이너
        bottomContainer.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }

        // 근무 상태 뷰
        workingStatusView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }

    // MARK: - Configure

    /// 초기 데이터 설정
    func configure(
        todayAmount: Int,
        startTime: String,
        endTime: String,
        startedAt: Date
    ) {
        // 월급 기둥 설정
        earningsStackView.configure(amount: todayAmount)

        // 근무 상태 설정
        workingStatusView.configure(
            startTime: startTime,
            endTime: endTime,
            startedAt: startedAt
        )
    }

    // MARK: - Public API

    /// 매 초마다 호출 (타이머 업데이트)
    func tick() {
        workingStatusView.tick()
    }

    /// 월급 금액 업데이트
    func updateAmount(_ amount: Int) {
        earningsStackView.updateAmount(amount)
    }

    /// 뱃지 상태 변경
    func updateBadgeType(_ type: BadgeType) {
        workingStatusView.updateBadgeType(type)
    }

    /// 애니메이션 시작
    func startAnimations() {
        earningsStackView.startAnimations()
    }

    /// 애니메이션 정지
    func stopAnimations() {
        earningsStackView.stopAnimations()
    }
}

// MARK: - WorkingStatusViewDelegate

extension WorkingContentView: WorkingStatusViewDelegate {

    func workingStatusViewDidTapScheduleAdjust(_ view: WorkingStatusView) {
        delegate?.workingContentViewDidTapScheduleAdjust(self)
    }
}
