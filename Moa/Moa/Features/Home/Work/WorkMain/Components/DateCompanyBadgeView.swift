//
//  DateCompanyBadgeView.swift
//  Moa
//

import UIKit
import SnapKit

/// 오늘 날짜 + 회사명을 캡슐 형태로 표시하는 뱃지 뷰
final class DateCompanyBadgeView: UIView {

    // MARK: - UI

    private let paydayIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image       = UIImage(resource: .Icon.iconClock).withRenderingMode(.alwaysTemplate)
        imageView.tintColor   = AppColor.IconAndText.mediumEmphasis
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let paydayLabel: UILabel = {
        let label = UILabel()
        label.font = AppTypography.b2_400.font()
        label.textColor = AppColor.IconAndText.highEmphasis
        return label
    }()

    private lazy var paydayItemStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [paydayIconView, paydayLabel])
        stack.axis      = .horizontal
        stack.alignment = .center
        stack.spacing   = 4
        return stack
    }()

    private let workplaceIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image       = UIImage(resource: .Icon.iconLocationPin).withRenderingMode(.alwaysTemplate)
        imageView.tintColor   = AppColor.IconAndText.mediumEmphasis
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let workplaceLabel: UILabel = {
        let label = UILabel()
        label.font = AppTypography.b2_400.font()
        label.textColor = AppColor.IconAndText.highEmphasis
        return label
    }()

    private lazy var workplaceItemStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [workplaceIconView, workplaceLabel])
        stack.axis      = .horizontal
        stack.alignment = .center
        stack.spacing   = 4
        return stack
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            paydayItemStack,
            workplaceItemStack
        ])
        stack.axis      = .horizontal
        stack.alignment = .center
        stack.spacing   = 10
        return stack
    }()

    // MARK: - Init

    init(workplace: String? = nil) {
        super.init(frame: .zero)

        setup()
        configure(workplace: workplace)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Layout

    private func setup() {
        backgroundColor = AppColor.Container.primary
        clipsToBounds   = true

        addSubview(contentStack)
        contentStack.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }

        paydayIconView.snp.makeConstraints    { $0.size.equalTo(16) }
        workplaceIconView.snp.makeConstraints { $0.size.equalTo(16) }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }

    // MARK: - Configure

    func configure(workplace: String?) {
        paydayLabel.text = Self.todayString()

        let hasCompany = !(workplace?.isEmpty ?? true)
        workplaceItemStack.isHidden = !hasCompany

        if let workplace {
            workplaceLabel.text = Self.truncatedText(workplace, limit: 10)
        }
    }
}

// MARK: - Date Formatter

private extension DateCompanyBadgeView {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 (E)"
        return formatter
    }()

    static func todayString() -> String {
        dateFormatter.string(from: Date())
    }
}

private extension DateCompanyBadgeView {
    static func truncatedText(_ text: String, limit: Int) -> String {
        guard text.count > limit else { return text }
        let index = text.index(text.startIndex, offsetBy: limit)
        return String(text[..<index]) + "..."
    }
}
