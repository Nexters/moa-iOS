//
//  LogoImageGuideView.swift
//  Moa
//
//  Created by mirim on 2/15/26.
//

import UIKit
import SnapKit
import Lottie

final class LogoImageGuideView: UIView {

    private let lottieView: LottieAnimationView = {
        let view = LottieAnimationView(name: "flying_money")
        view.loopMode = .loop
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()

    private let logoImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(resource: .Logo.login)
        view.contentMode = .scaleAspectFit
        return view
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "실시간으로 월급이 쌓이는 경험!"
        label.font = AppTypography.b1_400.font()
        label.textColor = AppColor.IconAndText.highEmphasis
        label.textAlignment = .center
        return label
    }()

    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        contentStack.addArrangedSubview(logoImageView)
        contentStack.addArrangedSubview(descriptionLabel)
        addSubViews([lottieView, contentStack])

        lottieView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        contentStack.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(40)
        }
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            lottieView.play()
        } else {
            lottieView.stop()
        }
    }
}
