//
//  SalaryDayOverlayView.swift
//  Moa
//

import UIKit
import SnapKit
import Lottie

final class SalaryOverlayView: UIView {

    // MARK: - UI

    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.Dim.primary
        return view
    }()

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .Image.imgDim)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        return imageView
    }()

    private let lottieView: LottieAnimationView = {
        let view = LottieAnimationView(name: "salary")
        view.loopMode = .loop
        view.contentMode = .scaleAspectFit
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppTypography.b2_500.font()
        label.textColor = AppColor.IconAndText.mediumEmphasis
        label.textAlignment = .center
        return label
    }()

    private let salaryLabel: StyledLabel = {
        let label = StyledLabel()
        label.textAlignment = .center
        return label
    }()

    private let descriptionLabel: StyledLabel = {
        let label = StyledLabel()
        label.setText(
            "오늘은 월급날!\n한 달간 열심히 일한 보상이에요",
            style: .init(
                typography: AppTypography.t3_500,
                color: AppColor.IconAndText.highEmphasis
            )
        )
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    private let captionLabel: StyledLabel = {
        let label = StyledLabel()
        label.setText(
            "월급액은 입력한 월급/연봉을 기준으로 계산돼요.",
            style: .init(
                typography: AppTypography.c1_400,
                color: AppColor.IconAndText.mediumEmphasis
            )
        )
        label.textAlignment = .center
        return label
    }()

    private let salaryText: String

    // MARK: - Init

    init(salaryText: String) {
        self.salaryText = salaryText
        super.init(frame: .zero)

        setupUI()
        setupGesture()
        configureMonthText()
        configureSalary()

        lottieView.play()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = .clear

        addSubViews([
            dimView,
            backgroundImageView,
            lottieView,
            titleLabel,
            salaryLabel,
            descriptionLabel,
            captionLabel
        ])

        dimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        backgroundImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        salaryLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.bottom.equalTo(salaryLabel.snp.top).offset(-4)
            $0.centerX.equalToSuperview()
        }

        lottieView.snp.makeConstraints {
            $0.bottom.equalTo(titleLabel.snp.top).offset(-8)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(140)
            $0.height.equalTo(100)
        }

        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(salaryLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }

        captionLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(6)
            $0.centerX.equalToSuperview()
        }
    }

    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissOverlay))
        addGestureRecognizer(tapGesture)
    }

    // MARK: - Configure

    private func configureSalary() {

        let fullText = "\(salaryText)원"

        let attributedString = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .font: AppTypography.h2_700.font(),
                .foregroundColor: AppColor.IconAndText.green
            ]
        )
        
        attributedString.addAttributes(
            [
                .font: AppTypography.h3_500.font(),
                .foregroundColor: AppColor.IconAndText.mediumEmphasis,
                .baselineOffset: 2
            ],
            range: NSRange(
                location: fullText.count - 1,
                length: 1
            )
        )
        
        attributedString.addAttribute(
            .kern,
            value: 6,
            range: NSRange(
                location: fullText.count - 2,
                length: 1
            )
        )

        salaryLabel.attributedText = attributedString
    }

    private func configureMonthText() {
        let month = Calendar.korea.component(.month, from: Date())
        titleLabel.text = "\(month)월 받는 월급"
    }

    // MARK: - Actions

    @objc private func dismissOverlay() {
        lottieView.stop()
        UIView.animate(
            withDuration: 0.25,
            animations: { self.alpha = 0 },
            completion:  { _ in self.removeFromSuperview() }
        )
    }
}

// MARK: - Presentation Logic

extension SalaryOverlayView {

    /// UserDefaults 키: 마지막으로 오버레이를 표시한 연-월을 "yyyy-MM" 형태로 저장
    private static let presentedMonthKey = "SalaryOverlayPresent"

    /// 이번 달에 아직 오버레이를 표시하지 않았으면 true
    static func shouldPresentThisMonth() -> Bool {
        let calendar = Calendar.korea
        let now      = Date()
        let year     = calendar.component(.year,  from: now)
        let month    = calendar.component(.month, from: now)
        let key      = "\(year)-\(String(format: "%02d", month))"
        let saved    = UserDefaults.standard.string(forKey: presentedMonthKey) ?? ""
        return saved != key
    }

    /// 이번 달에 표시했음을 UserDefaults에 기록
    static func markPresented() {
        let calendar = Calendar.korea
        let now      = Date()
        let year     = calendar.component(.year,  from: now)
        let month    = calendar.component(.month, from: now)
        let key      = "\(year)-\(String(format: "%02d", month))"
        UserDefaults.standard.set(key, forKey: presentedMonthKey)
    }
}
