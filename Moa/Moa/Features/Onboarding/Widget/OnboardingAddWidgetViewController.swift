//
//  OnboardingAddWidgetViewController.swift
//  Moa
//
//  Created by mirim on 4/22/26.
//

import UIKit
import SnapKit

final class OnboardingAddWidgetViewController: BaseViewController {

    // MARK: - Constants

    private enum Constants {
        static let title = "홈 화면에 위젯을 추가할까요?"
        static let description = "앱을 열지 않아도 홈 화면에서 오늘 번 돈을\n실시간으로 확인할 수 있어요."
        static let primaryButtonTitle = "위젯 추가하기"
        static let secondaryButtonTitle = "다음에 할게요"
    }

    // MARK: - Dependencies

    private let viewModel: OnboardingAddWidgetViewModel
    private let onNext: (() -> Void)

    // MARK: - UI Components

    private let titleLabel: UILabel = {
        let label = StyledLabel()
        label.setText(
            Constants.title,
            style: .init(
                typography: AppTypography.t1_700,
                color: AppColor.IconAndText.highEmphasis
            )
        )
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = StyledLabel()
        label.setText(
            Constants.description,
            style: .init(
                typography: AppTypography.b2_400,
                color: AppColor.IconAndText.mediumEmphasis
            )
        )
        label.numberOfLines = 0
        return label
    }()

    private let textStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 8
        return stack
    }()

    private let widgetImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .Image.imgWidget)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var addWidgetButton: AppButton = {
        let button = AppButton()
        button.setTitle(Constants.primaryButtonTitle, for: .normal)
        button.applyStyle(.primary())
        button.addTarget(self, action: #selector(didTapPrimaryButton), for: .touchUpInside)
        return button
    }()

    private lazy var laterButton: UnderlineTextButton = {
        let button = UnderlineTextButton(
            title: Constants.secondaryButtonTitle,
            style: .default
        )
        button.addTarget(self, action: #selector(didTapSecondaryButton), for: .touchUpInside)
        return button
    }()

    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()

    init(viewModel: OnboardingAddWidgetViewModel, onNext: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onNext = onNext
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    override func setupUI() {
        setupHierarchy()
        setupLayout()
    }
}

// MARK: - UI Configuration

private extension OnboardingAddWidgetViewController {
    func setupHierarchy() {
        textStack.addArrangedSubViews([titleLabel, descriptionLabel])
        buttonStack.addArrangedSubViews([addWidgetButton, laterButton])
        view.addSubViews([textStack, widgetImageView, buttonStack])
    }

    func setupLayout() {
        textStack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.screenHorizontal)
        }

        let imageSize = UIImage(resource: .Image.imgWidget).size
        let ratio = imageSize.width > 0 ? imageSize.height / imageSize.width : 1.0
        widgetImageView.snp.makeConstraints { make in
            make.top.equalTo(textStack.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(widgetImageView.snp.width).multipliedBy(ratio)
        }

        buttonStack.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.screenHorizontal)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.ctaBottom)
        }
    }
}

// MARK: - Actions

private extension OnboardingAddWidgetViewController {
    @objc func didTapPrimaryButton() {
        // TODO: 위젯 추가하기 액션
    }

    @objc func didTapSecondaryButton() {
        // TODO: 다음에 할게요 액션 (홈으로 진입)
    }
}

// MARK: - Preview

@available(iOS 17.0)
#Preview {
    OnboardingAddWidgetViewController(
        viewModel: OnboardingAddWidgetViewModel(),
        onNext: {}
    )
}
