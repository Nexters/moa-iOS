//
//  WorkScheduleChangeCardView.swift
//  Moa
//
//  Created by 정도현 on 2/20/26.
//

import UIKit
import SnapKit

final class WorkScheduleChangeCardView: UIView {

    // MARK: - Properties

    let scheduleChangeType: WorkScheduleChangeType
    var onTap: ((WorkScheduleChangeType) -> Void)?

    // MARK: - UI

    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = scheduleChangeType.description
        label.font = AppTypography.b1_400.font()
        label.textColor = AppColor.IconAndText.mediumEmphasis
        label.textAlignment = .center
        return label
    }()

    // MARK: - Init

    init(type: WorkScheduleChangeType) {
        self.scheduleChangeType = type
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setup() {
        layer.cornerRadius = 12
        clipsToBounds      = true
        backgroundColor = AppColor.Btn.Secondary.pressed

        addSubview(label)
        label.snp.makeConstraints { $0.center.equalToSuperview() }
        snp.makeConstraints { $0.height.equalTo(54) }

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        setSelected(false)
    }

    // MARK: - State

    func setSelected(_ selected: Bool) {
        label.font        = selected ? AppTypography.b1_600.font()          : AppTypography.b1_400.font()
        label.textColor   = selected ? AppColor.IconAndText.green            : AppColor.IconAndText.highEmphasis
        layer.borderWidth = selected ? 1                                     : 0
        layer.borderColor = selected ? AppColor.IconAndText.green.cgColor    : nil
    }

    // MARK: - Action

    @objc private func handleTap() {
        onTap?(scheduleChangeType)
    }
}
