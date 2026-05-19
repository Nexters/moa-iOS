//
//  WorkDurationView.swift
//  Moa
//
//  Created by 정도현 on 5/19/26.
//

import UIKit
import SnapKit

final class WorkDurationView: UIView {

    // MARK: - UI

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [attentionImageView, durationLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 4
        return stack
    }()

    private let durationLabel: StyledLabel = {
        let label = StyledLabel()
        label.setStyle(
            .init(
                typography: AppTypography.b2_500,
                color: AppColor.IconAndText.green
            )
        )
        return label
    }()

    private let attentionImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(resource: .Icon.iconAttentionCircle)
            .withRenderingMode(.alwaysTemplate)
        iv.tintColor = AppColor.IconAndText.green
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(stackView)

        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        attentionImageView.snp.makeConstraints {
            $0.size.equalTo(16)
        }

        attentionImageView.transform = CGAffineTransform(translationX: 0, y: -1)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Public

    func configure(start: String, end: String) {
        let text = makeDurationText(start: start, end: end)

        durationLabel.setText(text)
        isHidden = text.isEmpty
    }
}

private extension WorkDurationView {

    func makeDurationText(start: String, end: String) -> String {
        let formatter = DateFormatter.hourMinuteFormatter

        guard
            let startDate = formatter.date(from: start),
            let endDate = formatter.date(from: end)
        else {
            return ""
        }

        var diff = Int(endDate.timeIntervalSince(startDate))

        // 익일 퇴근 처리
        if diff <= 0 {
            diff += 24 * 60 * 60
        }

        let hours = diff / 3600
        let minutes = (diff % 3600) / 60

        if minutes == 0 {
            return "총 \(hours)시간 근무해요."
        } else {
            return "총 \(hours)시간 \(minutes)분 근무해요."
        }
    }
}
