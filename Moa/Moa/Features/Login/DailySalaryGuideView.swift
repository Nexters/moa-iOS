//
//  DailySalaryGuideView.swift
//  Moa
//
//  Created by mirim on 2/15/26.
//

import UIKit
import SnapKit
import Lottie

/// 가이드 페이저 두번째 뷰 (오늘 쌓은 월급)
final class DailySalaryGuideView: UIView {
    
    // MARK: - Constants
    
    private enum Constant {
        static let todaysEarnedSalary = "오늘 쌓은 월급"
        static let exampleAmount = "12,000원"
        static let exampleAmountHighlight = "12,000"
        static let largeTitleText = "오늘도 쌓이는 내 월급"
        static let largeTitleHighlight = "오늘도 쌓이는"
        static let descriptionText = "출퇴근 시간과 급여만 입력하면\n오늘 번 월급을 자동으로 계산해드려요."
        static let imageHeight = 147
    }
    
    // MARK: - UI Components
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [todaysEarnedSalaryLabel, exampleAmountLabel, moneyStackLottieView, largeTitleLabel, descriptionLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 0
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 40, left: 20, bottom: 32, right: 20)
        stackView.setCustomSpacing(0, after: todaysEarnedSalaryLabel)
        stackView.setCustomSpacing(14, after: exampleAmountLabel)
        stackView.setCustomSpacing(22, after: moneyStackLottieView)
        stackView.setCustomSpacing(6, after: largeTitleLabel)
        return stackView
    }()
    
    private let todaysEarnedSalaryLabel: StyledLabel = {
        let label = StyledLabel()
        label.setText(
            Constant.todaysEarnedSalary,
            style: .init(
                typography: AppTypography.b2_500,
                color: AppColor.IconAndText.mediumEmphasis
            )
        )
        return label
    }()
    
    private let exampleAmountLabel: StyledLabel = {
        let label = StyledLabel()
        let attr = NSAttributedString.styled(
            baseText: Constant.exampleAmount,
            baseTypography: AppTypography.h3_500.font(),
            baseColor: AppColor.IconAndText.mediumEmphasis,
            highlights: [
                (
                    substring: Constant.exampleAmountHighlight,
                    typography: AppTypography.h2_700.font(),
                    color: AppColor.IconAndText.highEmphasis
                )
            ]
        )
        label.attributedText = attr
        return label
    }()
    
    private let moneyStackLottieView: LottieAnimationView = {
        let view = LottieAnimationView(name: "money_stack")
        view.loopMode = .loop
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let largeTitleLabel: StyledLabel = {
        let label = StyledLabel()
        let attr = NSAttributedString.styled(
            baseText: Constant.largeTitleText,
            baseTypography: AppTypography.t1_700.font(),
            baseColor: AppColor.IconAndText.highEmphasis,
            highlights: [
                (
                    substring: Constant.largeTitleHighlight,
                    typography: AppTypography.t1_700.font(),
                    color: AppColor.IconAndText.green
                )
            ]
        )
        label.attributedText = attr
        return label
    }()
    
    private let descriptionLabel: StyledLabel = {
        let label = StyledLabel()
        label.setText(
            Constant.descriptionText,
            style: .init(
                typography: AppTypography.b2_400,
                color: AppColor.IconAndText.mediumEmphasis
            )
        )
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        setupUI()
        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func play() {
        moneyStackLottieView.play()
    }

    func stop() {
        moneyStackLottieView.stop()
    }

    // MARK: - Setup
    
    private func setupUI() {
        self.backgroundColor = AppColor.Container.primary
        self.layer.cornerRadius = 26
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(16)
            make.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
        }
        
        moneyStackLottieView.snp.makeConstraints { make in
            make.height.equalTo(Constant.imageHeight)
        }
    }
}
