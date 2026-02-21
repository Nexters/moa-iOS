//
//  WorkScheduleCard.swift
//  Moa
//

//
//  WorkScheduleCard.swift
//  Moa
//

import UIKit
import SnapKit

// MARK: - WorkScheduleType

enum WorkScheduleType {
    case worked(startTime: String, endTime: String)
    case scheduled(startTime: String, endTime: String)
    case payday(schedule: String, salary: String)   // e.g. "매달 25일", "2,000,000"
    case vacation(startTime: String, endTime: String)

    var titleText: String {
        switch self {
        case .worked:    return "근무 완료"
        case .scheduled: return "근무 예정"
        case let .payday(schedule, _):    return "월급날 · 매달 \(schedule)일"
        case .vacation:  return "휴가"
        }
    }

    /// titleLabel 오른쪽 보조 텍스트 (payday만 사용)
    var subtitleText: String? {
        guard case .payday(let schedule, _) = self else { return nil }
        return schedule
    }

    var mainText: String {
        switch self {
        case .worked(let s, let e),
             .scheduled(let s, let e),
             .vacation(let s, let e): return "\(s) - \(e)"
        case .payday(_, let salary):  return "+ \(salary)원"
        }
    }

    var mainColor: UIColor {
        return AppColor.IconAndText.highEmphasis
    }

    var iconImage: UIImage? {
        switch self {
        case .worked:    return UIImage(resource: .Icon.iconTicketWorked)
        case .scheduled: return UIImage(resource: .Icon.iconTicektScheduled)
        case .payday:    return UIImage(resource: .Icon.iconTicketPayday)
        case .vacation:  return UIImage(resource: .Icon.iconTicketVacation)
        }
    }
}

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

    private static func make(_ type: WorkScheduleType, onTap: (() -> Void)?) -> WorkScheduleTicket {
        let card = WorkScheduleTicket(type: type)
        card.onTap = onTap
        return card
    }
}
