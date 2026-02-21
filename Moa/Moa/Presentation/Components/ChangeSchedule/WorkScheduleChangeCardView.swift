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
        label.font = AppTypography.b1_600.font()
        label.textColor = AppColor.IconAndText.highEmphasis
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

        addSubview(label)
        label.snp.makeConstraints { $0.center.equalToSuperview() }
        snp.makeConstraints { $0.height.equalTo(54) }

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        setSelected(false)
    }

    // MARK: - State

    func setSelected(_ selected: Bool) {
        backgroundColor = selected ?
             AppColor.Btn.Secondary.enable
            : AppColor.Btn.Secondary.disabled
    }

    // MARK: - Action

    @objc private func handleTap() {
        onTap?(scheduleChangeType)
    }
}
