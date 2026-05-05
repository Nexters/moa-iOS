//
//  OnboardingAddWidgetViewController.swift
//  Moa
//
//  Created by mirim on 4/22/26.
//

import UIKit
import SnapKit

final class OnboardingAddWidgetViewController: BaseViewController {

    private enum Constants {
        static let title = "홈 화면에 위젯을 추가하세요"
        static let description = "앱을 열지 않아도 홈 화면에서 오늘 번 돈을\n실시간으로 확인할 수 있어요."
        static let confirmButtonTitle = "확인"
    }

    // MARK: - Dependencies

    private let viewModel: OnboardingAddWidgetViewModel
    private let onNext: () -> Void

    // MARK: - UI

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = false
        return sv
    }()

    private let contentView = UIView()

    private let titleLabel: StyledLabel = {
        let label = StyledLabel()
        label.setText(
            Constants.title,
            style: .init(typography: AppTypography.t1_700, color: AppColor.IconAndText.highEmphasis)
        )
        label.numberOfLines = 0
        return label
    }()

    private let descriptionLabel: StyledLabel = {
        let label = StyledLabel()
        label.setText(
            Constants.description,
            style: .init(typography: AppTypography.b2_400, color: AppColor.IconAndText.mediumEmphasis)
        )
        label.numberOfLines = 0
        return label
    }()

    private let headerStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 8
        sv.alignment = .leading
        return sv
    }()

    private let stepsStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 14
        return sv
    }()

    private lazy var confirmButton: AppButton = {
        let button = AppButton()
        button.setTitle(Constants.confirmButtonTitle, for: .normal)
        button.applyStyle(.primary())
        button.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
        return button
    }()

    // MARK: - Init

    init(viewModel: OnboardingAddWidgetViewModel, onNext: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onNext = onNext
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    override func setupUI() {
        replaceSystemBackButtonWithAppBackButton()
        setupHierarchy()
        setupLayout()
    }
}

// MARK: - UI Configuration

private extension OnboardingAddWidgetViewController {

    func setupHierarchy() {
        headerStack.addArrangedSubViews([titleLabel, descriptionLabel])

        let step1 = makeStepCard(
            number: "1",
            text: makeAttributedText(parts: [
                ("홈 화면을 길게 눌러\n", false),
                ("'편집'", true),
                (" 버튼을 탭하세요.", false)
            ]),
            image: UIImage(resource: .Image.imgAddWidgetStep1)
        )
        let step2 = makeStepCard(
            number: "2",
            text: makeAttributedText(parts: [
                ("'Moa'를 검색하고", true),
                ("\n위젯을 추가하세요.", false)
            ]),
            image: UIImage(resource: .Image.imgAddWidgetStep2)
        )
        let step3 = makeStepCard(
            number: "3",
            text: makeAttributedText(parts: [
                ("위젯을 ", false),
                ("원하는 위치", true),
                ("에\n배치하세요!", false)
            ]),
            image: UIImage(resource: .Image.imgAddWidgetStep3)
        )

        stepsStack.addArrangedSubViews([step1, step2, step3])
        contentView.addSubViews([headerStack, stepsStack])
        scrollView.addSubview(contentView)
        view.addSubViews([scrollView, confirmButton])
    }

    func setupLayout() {
        confirmButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.ctaBottom)
        }

        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(confirmButton.snp.top).offset(-16)
        }

        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }

        headerStack.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
        }

        stepsStack.snp.makeConstraints {
            $0.top.equalTo(headerStack.snp.bottom).offset(36)
            $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
            $0.bottom.equalToSuperview().inset(20)
        }
    }

    func makeStepCard(number: String, text: NSAttributedString, image: UIImage) -> UIView {
        let container = UIView()
        container.backgroundColor = AppColor.Container.primary
        container.layer.cornerRadius = 16
        container.clipsToBounds = true

        let numberLabel = StyledLabel()
        numberLabel.setText(
            number,
            style: .init(typography: AppTypography.t3_700, color: AppColor.IconAndText.mediumEmphasis)
        )

        let textLabel = UILabel()
        textLabel.attributedText = text
        textLabel.numberOfLines = 0

        let leftStack = UIStackView(arrangedSubviews: [numberLabel, textLabel])
        leftStack.axis = .vertical
        leftStack.spacing = 6
        leftStack.alignment = .leading

        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        container.addSubViews([leftStack, imageView])

        leftStack.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(16)
            $0.trailing.equalTo(imageView.snp.leading).offset(-8)
            $0.bottom.lessThanOrEqualToSuperview().inset(16)
        }

        imageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(26)
            $0.trailing.bottom.equalToSuperview()
        }

        return container
    }

    func makeAttributedText(parts: [(String, Bool)]) -> NSAttributedString {
        let result = NSMutableAttributedString()
        for (text, isHighlight) in parts {
            let attrs: [NSAttributedString.Key: Any] = isHighlight
                ? [.font: AppTypography.b1_600.font(), .foregroundColor: AppColor.IconAndText.green]
                : [.font: AppTypography.b1_500.font(), .foregroundColor: AppColor.IconAndText.highEmphasis]
            result.append(NSAttributedString(string: text, attributes: attrs))
        }
        return result
    }
}

// MARK: - Actions

private extension OnboardingAddWidgetViewController {
    @objc func didTapConfirm() {
        Analytics.track(.widgetAddClicked)
        onNext()
    }
}

// MARK: - Preview

@available(iOS 17.0, *)
#Preview {
    OnboardingAddWidgetViewController(
        viewModel: OnboardingAddWidgetViewModel(),
        onNext: {}
    )
}
