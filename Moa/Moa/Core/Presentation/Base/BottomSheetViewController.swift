//
//  BaseBottomSheet.swift
//  Moa
//
//  Created by 정도현 on 2/10/26.
//


import UIKit
import SnapKit

// MARK: - BottomSheet Configuration
struct BottomSheetConfiguration {
    let cornerRadius: CGFloat
    let handleHeight: CGFloat
    let handleWidth: CGFloat
    let handleTopPadding: CGFloat
    let dimmedAlpha: CGFloat
    let springDamping: CGFloat
    let springVelocity: CGFloat
    
    static let `default` = BottomSheetConfiguration(
        cornerRadius: 24,
        handleHeight: 5,
        handleWidth: 32,
        handleTopPadding: 16,
        dimmedAlpha: 0.6,
        springDamping: 0.8,
        springVelocity: 0.5
    )
}

// MARK: - BottomSheet Presentable Protocol
protocol BottomSheetPresentable: UIViewController {
    var preferredHeight: CGFloat { get }
    var allowsDismissalByDrag: Bool { get }
}

extension BottomSheetPresentable {

    var allowsDismissalByDrag: Bool { true }

    var preferredHeight: CGFloat {
        view.layoutIfNeeded()

        let targetWidth = UIScreen.main.bounds.width
        let targetSize = CGSize(
            width: targetWidth,
            height: UIView.layoutFittingCompressedSize.height
        )

        let size = view.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        return size.height
    }
}

// MARK: - BottomSheet Delegate
protocol BottomSheetViewControllerDelegate: AnyObject {
    func bottomSheetWillDismiss(_ controller: BottomSheetViewController)
    func bottomSheetDidDismiss(_ controller: BottomSheetViewController)
}

extension BottomSheetViewControllerDelegate {
    func bottomSheetWillDismiss(_ controller: BottomSheetViewController) {}
    func bottomSheetDidDismiss(_ controller: BottomSheetViewController) {}
}

// MARK: - BottomSheet ViewController
final class BottomSheetViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: BottomSheetViewControllerDelegate?
    
    private let contentViewController: BottomSheetPresentable
    private let configuration: BottomSheetConfiguration
    
    private var bottomSheetHeight: CGFloat {
        contentViewController.preferredHeight
    }
    
    private var defaultHeight: CGFloat {
        return bottomSheetHeight
    }
    
    private var dismissibleHeight: CGFloat {
        return bottomSheetHeight * 0.3
    }
    
    // MARK: - UI Components
    
    // Background Dimmed View
    private lazy var dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.Dim.primary
        view.alpha = 0
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dimmedViewTapped))
        view.addGestureRecognizer(tapGesture)
        
        return view
    }()
    
    // BottomSheet Container
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = false
        return view
    }()
    
    // BottomSheet Background
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.Container.primary
        view.layer.cornerRadius = configuration.cornerRadius
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var handleView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.IconAndText.lowEmphasis
        view.layer.cornerRadius = configuration.handleHeight / 2
        return view
    }()
    
    private var containerViewBottomConstraint: Constraint?
    private var containerViewHeightConstraint: Constraint?
    
    private var interactionController: UIPercentDrivenInteractiveTransition?
    private var isInteracting = false
    
    // MARK: - Initialization
    init(
        contentViewController: BottomSheetPresentable,
        configuration: BottomSheetConfiguration = .default
    ) {
        self.contentViewController = contentViewController
        self.configuration = configuration

        super.init(nibName: nil, bundle: nil)
        
        transitioningDelegate = self
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupGestures()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animatePresent()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // intrinsic size 기반 높이 계산
        let targetSize = CGSize(
            width: view.bounds.width,
            height: UIView.layoutFittingCompressedSize.height
        )

        let contentHeight =
            contentViewController.view.systemLayoutSizeFitting(
                targetSize,
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            ).height

        // handle + padding 포함 최종 높이
        let totalHeight =
            contentHeight
            + configuration.handleTopPadding
            + configuration.handleHeight
            + configuration.handleTopPadding

        // 최초 1회만 업데이트 (무한 layout 방지)
        guard containerViewHeightConstraint?.layoutConstraints.first?.constant != totalHeight else {
            return
        }

        containerViewHeightConstraint?.update(offset: totalHeight)

        // 처음에는 아래에 숨김
        containerViewBottomConstraint?.update(offset: totalHeight)
        view.layoutIfNeeded()
    }

    
    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = .clear

        // Dimmed View
        view.addSubview(dimmedView)
        dimmedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // Container View
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            containerViewHeightConstraint =
                make.height.equalTo(0).constraint
            containerViewBottomConstraint =
                make.bottom.equalToSuperview()
                    .offset(0)
                    .constraint
        }

        // Background View
        containerView.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // Handle View
        backgroundView.addSubview(handleView)
        handleView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
                .offset(configuration.handleTopPadding)
            make.width.equalTo(configuration.handleWidth)
            make.height.equalTo(configuration.handleHeight)
        }

        // Content ViewController
        addChild(contentViewController)
        backgroundView.addSubview(contentViewController.view)
        contentViewController.view.snp.makeConstraints { make in
            make.top.equalTo(handleView.snp.bottom)
                .offset(configuration.handleTopPadding)
            make.leading.trailing.equalToSuperview()

            make.bottom.equalToSuperview().priority(.low)
        }
        contentViewController.didMove(toParent: self)
    }

    
    private func setupGestures() {
        guard contentViewController.allowsDismissalByDrag else { return }
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        containerView.addGestureRecognizer(panGesture)
    }
    
    // MARK: - Animations
    private func animatePresent() {
        containerViewBottomConstraint?.update(offset: 0)
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: configuration.springDamping,
            initialSpringVelocity: configuration.springVelocity,
            options: .curveEaseInOut
        ) { [weak self] in
            guard let self = self else { return }
            self.dimmedView.alpha = 1
            self.view.layoutIfNeeded()
        }
    }
    
    func animateDismiss(completion: (() -> Void)? = nil) {
        delegate?.bottomSheetWillDismiss(self)
        
        containerViewBottomConstraint?.update(offset: defaultHeight)
        
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: .curveEaseInOut
        ) { [weak self] in
            self?.dimmedView.alpha = 0
            self?.view.layoutIfNeeded()
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.dismiss(animated: false) {
                self.delegate?.bottomSheetDidDismiss(self)
                completion?()
            }
        }
    }
    
    // MARK: - Gesture Handlers
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let verticalMovement = max(translation.y, 0)
        let percent = min(verticalMovement / defaultHeight, 1)

        switch gesture.state {
        case .began:
            isInteracting = true
            interactionController = UIPercentDrivenInteractiveTransition()
            dismiss(animated: true)

        case .changed:
            interactionController?.update(percent)

        case .ended, .cancelled:
            isInteracting = false

            if percent > 0.3 || gesture.velocity(in: view).y > 1000 {
                interactionController?.finish()
            } else {
                interactionController?.cancel()
            }

            interactionController = nil

        default:
            break
        }
    }
    
    @objc private func dimmedViewTapped() {
        animateDismiss()
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension BottomSheetViewController: UIViewControllerTransitioningDelegate {
    func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        BottomSheetDismissAnimator(configuration: configuration)
    }

    func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        isInteracting ? interactionController : nil
    }
}
