//
//  WorkScheduleCard.swift
//  Moa
//

import UIKit
import SnapKit

// MARK: - WorkScheduleCard

final class WorkScheduleTicket: UIView {

    // MARK: Event

    var onTap: (() -> Void)?

    // MARK: Subviews

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode   = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()

    private let titleLabel    = StyledLabel()
    private let mainLabel     = StyledLabel()

    private let chevronView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(resource: .Icon.iconChevronRight)
            .withRenderingMode(.alwaysTemplate)
        iv.tintColor = AppColor.IconAndText.lowEmphasis
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: Init

    init(type: WorkScheduleType) {
        super.init(frame: .zero)
        setupView()
        setupLayout()
        apply(type: type)
        setupTap()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: Setup

    private func setupView() {
        backgroundColor    = AppColor.Container.primary
        layer.cornerRadius = 16
        clipsToBounds      = true
        snp.makeConstraints { $0.height.equalTo(70) }
    }

    private func setupLayout() {
        addSubViews([iconImageView, titleLabel, mainLabel, chevronView])

        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(CGSize(width: 40, height: 40))
        }
        chevronView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(CGSize(width: 24, height: 24))
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalTo(iconImageView.snp.trailing).offset(12)
        }
        mainLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(36)
            $0.leading.equalTo(iconImageView.snp.trailing).offset(12)
            $0.trailing.lessThanOrEqualTo(chevronView.snp.leading).offset(-12)
        }
    }

    private func apply(type: WorkScheduleType) {
        iconImageView.image = type.iconImage

        titleLabel.setText(type.titleText, style: .init(
            typography: AppTypography.c1_400,
            color: AppColor.IconAndText.mediumEmphasis
        ))

        mainLabel.setText(type.mainText, style: .init(
            typography: AppTypography.b1_500,
            color: type.mainColor
        ))
    }

    private func setupTap() {
        isUserInteractionEnabled = true
        addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTap))
        )
    }

    @objc private func didTap() { onTap?() }
}

// MARK: - Factory

extension WorkScheduleTicket {

    static func worked(startTime: String, endTime: String, onTap: (() -> Void)? = nil) -> WorkScheduleTicket {
        make(.worked(startTime: startTime, endTime: endTime), onTap: onTap)
    }

    static func scheduled(startTime: String, endTime: String, onTap: (() -> Void)? = nil) -> WorkScheduleTicket {
        make(.scheduled(startTime: startTime, endTime: endTime), onTap: onTap)
    }

    static func payday(schedule: String, salary: String, onTap: (() -> Void)? = nil) -> WorkScheduleTicket {
        make(.payday(schedule: schedule, salary: salary), onTap: onTap)
    }

    static func vacation(startTime: String, endTime: String, onTap: (() -> Void)? = nil) -> WorkScheduleTicket {
        make(.vacation(startTime: startTime, endTime: endTime), onTap: onTap)
    }
    
    static func publicHoliday(onTap: (() -> Void)? = nil) -> WorkScheduleTicket {
        make(.publicHoliday, onTap: onTap)
    }

    private static func make(_ type: WorkScheduleType, onTap: (() -> Void)?) -> WorkScheduleTicket {
        let card = WorkScheduleTicket(type: type)
        card.onTap = onTap
        return card
    }
}
