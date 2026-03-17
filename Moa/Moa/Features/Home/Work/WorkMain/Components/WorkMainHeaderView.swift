//
//  WorkMainHeaderView.swift
//  Moa
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

    func configure(data: HomeEntity, status: WorkStatusEntity) {
        badgeView.configure(workplace: data.workplace)

        salaryView.configure(
            .init(
                workedEarnings: data.workedEarnings,
                standardSalary: data.standardSalary,
                type:           data.type,
                workStatus:     status
            )
        )

        summaryView.configure(status: status, data: data)
    }
}
