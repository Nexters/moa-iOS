//
//  ScheduleDateRangeCardView.swift
//  Moa
//
//  날짜 구간 선택 카드
//  - readonly: mediumEmphasis 색상, chevron 숨김, 탭 불가
//  - editable: highEmphasis 색상, chevron 표시, 탭 → onTap 클로저 호출
//

import UIKit
import SnapKit

final class ScheduleDateRangeCardView: UIView {

    // MARK: - Callback

    var onTap: (() -> Void)?

    // MARK: - State

    private var isReadonly: Bool = false

    // MARK: - UI

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font          = AppTypography.b1_400.font()
        label.textColor     = AppColor.IconAndText.lowEmphasis
        label.numberOfLines = 1
        return label
    }()

    private let chevronView: UIImageView = {
        let iv = UIImageView()
        iv.image       = UIImage(resource: .Icon.iconChevronDown).withRenderingMode(.alwaysTemplate)
        iv.tintColor   = AppColor.IconAndText.highEmphasis
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGesture()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor    = AppColor.Container.primary
        layer.cornerRadius = 12
        clipsToBounds      = true

        addSubViews([dateLabel, chevronView])

        dateLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(chevronView.snp.leading).offset(-8)
        }
        chevronView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(20)
        }
        snp.makeConstraints {
            $0.height.equalTo(60)
        }
    }

    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }

    // MARK: - Configure

    /// - Parameters:
    ///   - dateRange: 선택된 날짜 범위. nil이면 placeholder 표시
    ///   - readonly: true면 탭 불가 + mediumEmphasis 색상 + chevron 숨김
    func configure(dateRange: ScheduleDateRangeEntity?, readonly: Bool = false) {
        isReadonly = readonly

        let hasDate   = dateRange != nil
        let textColor: UIColor

        if readonly {
            // 날짜 고정 모드
            textColor = AppColor.IconAndText.mediumEmphasis
        } else {
            // 편집 가능 모드
            textColor = AppColor.IconAndText.highEmphasis
        }
        
        dateLabel.text      = dateRange?.displayString ?? Date().koreanDateString
        dateLabel.font      = AppTypography.t2_700.font()
        dateLabel.textColor = textColor

        chevronView.isHidden = readonly
        isUserInteractionEnabled = !readonly
    }

    // MARK: - Action

    @objc private func didTap() {
        guard !isReadonly else { return }
        onTap?()
    }
}
