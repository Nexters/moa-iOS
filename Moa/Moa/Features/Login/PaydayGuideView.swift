//
//  PaydayGuideView.swift
//  Moa
//
//  Created by mirim on 2/15/26.
//

import UIKit
import SnapKit
import Lottie

/// 가이드 페이저 세번째 뷰 (오늘은 월급날!)
final class PaydayGuideView: UIView {
    
    // MARK: - Constants
    
    private enum Constant {
        static let todayIsPayday = "오늘은 월급날!"
        static let exampleAmount = "3,400,000원"
        static let exampleAmountHighlight = "3,400,000"
        static let largeTitleText = "당신의 존버를 함께해요"
        static let largeTitleHighlight = "존버"
        static let descriptionText = "월급날만 기다리지 말고\n지금 버는 돈을 보면서 같이 존버해요!"
        static let imageHeight = 160
        static let lottieFileName = "money_coin"
    }
    
    // MARK: - UI Components
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [todayIsPaydayLabel, exampleAmountLabel, coinsLottieView, largeTitleLabel, descriptionLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.spacing = 0
        stackView.layoutMargins = UIEdgeInsets(top: 40, left: 20, bottom: 32, right: 20)
        stackView.setCustomSpacing(0, after: todayIsPaydayLabel)
        stackView.setCustomSpacing(14, after: exampleAmountLabel)
        stackView.setCustomSpacing(22, after: coinsLottieView)
        stackView.setCustomSpacing(6, after: largeTitleLabel)
        return stackView
    }()
    
    private let todayIsPaydayLabel: StyledLabel = {
        let label = StyledLabel()
        label.setText(
            Constant.todayIsPayday,
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
    
    private let coinsLottieView: LottieAnimationView = {
        let view = LottieAnimationView(name: Constant.lottieFileName)
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

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            coinsLottieView.play()
        } else {
            coinsLottieView.stop()
        }
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
        
        coinsLottieView.snp.makeConstraints { make in
            make.height.equalTo(Constant.imageHeight)
        }
    }
}
