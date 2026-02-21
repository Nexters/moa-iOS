//
//  WorkMainHeaderView.swift
//  Moa
//
//  Created by 정도현 on 2/20/26.
//

import UIKit
import SnapKit

protocol WorkMainHeaderViewDelegate: AnyObject {
    func workMainHeaderViewDidTapTimeRow(_ view: WorkMainHeaderView)
}

/// DateCompanyBadgeView + MonthlySalaryView + WorkMainSummaryView 조합
final class WorkMainHeaderView: UIView {

    // MARK: - Delegate

    weak var delegate: WorkMainHeaderViewDelegate?

    // MARK: - UI

    private let badgeView  = DateCompanyBadgeView()
    private let salaryView = MonthlySalaryView()

    private lazy var summaryView: WorkMainSummaryView = {
        let view = WorkMainSummaryView()
        view.onTapTimeRow = { [weak self] in
            guard let self else { return }
            delegate?.workMainHeaderViewDidTapTimeRow(self)
        }
        return view
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [badgeView, salaryView, summaryView])
        stack.axis      = .vertical
        stack.alignment = .center
        stack.setCustomSpacing(28, after: badgeView)
        stack.setCustomSpacing(42, after: salaryView)
        return stack
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setup() {
        addSubview(contentStack)
        contentStack.snp.makeConstraints { $0.edges.equalToSuperview() }
        [salaryView, summaryView].forEach {
            $0.snp.makeConstraints { $0.leading.trailing.equalToSuperview() }
        }
    }

    // MARK: - Configure

    func configure(with display: HomeDisplayData) {
        let month = Calendar.current.component(.month, from: Date())

        badgeView.configure(workplace: display.workplace)

        salaryView.configure(.init(
            month:         month,
            amount:        display.dailyWage,
            baseAmount:    display.dailyWage,    // TODO: 기본 월급 API 연동 후 교체
            scheduleType:  display.scheduleStatus,
            shouldAnimate: false
        ))

        summaryView.configure(with: display)
    }
}
