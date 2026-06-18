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
        dimmedAlpha: 0.0,
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

    /// 현재 기기의 하단 SafeArea 높이
    private var safeAreaBottomInset: CGFloat {
        view.safeAreaInsets.bottom
    }
    
    // MARK: - UI Components
    private lazy var dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.Dim.primary
        view.alpha = 0
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dimmedViewTapped))
        view.addGestureRecognizer(tapGesture)
        
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = false
        return view
    }()
    
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.Container.primary
        view.layer.cornerRadius = configuration.cornerRadius
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

    // MARK: - Initialization
    init(
        contentViewController: BottomSheetPresentable,
        configuration: BottomSheetConfiguration = .default
    ) {
        self.contentViewController = contentViewController
        self.configuration = configuration
        
        super.init(nibName: nil, bundle: nil)
        
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
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        view.setNeedsLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animatePresent()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let contentHeight = contentViewController.preferredHeight
        
        let totalHeight = contentHeight
            + configuration.handleTopPadding
            + configuration.handleHeight
            + configuration.handleTopPadding
            + safeAreaBottomInset

        guard containerViewHeightConstraint?.layoutConstraints.first?.constant != totalHeight else {
            return
        }
        
        containerViewHeightConstraint?.update(offset: totalHeight)
        view.layoutIfNeeded()
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = .clear
        
        view.addSubview(dimmedView)
        dimmedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            containerViewHeightConstraint = make.height.equalTo(0).constraint
            containerViewBottomConstraint = make.bottom.equalToSuperview().offset(0).constraint
        }
        
        containerView.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        backgroundView.addSubview(handleView)
        handleView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(configuration.handleTopPadding)
            make.width.equalTo(configuration.handleWidth)
            make.height.equalTo(configuration.handleHeight)
        }
        
        addChild(contentViewController)
        backgroundView.addSubview(contentViewController.view)
        contentViewController.view.snp.makeConstraints { make in
            make.top.equalTo(handleView.snp.bottom).offset(configuration.handleTopPadding)
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
        let velocity = gesture.velocity(in: view)
        let offset = max(translation.y, 0)
        
        switch gesture.state {
        case .changed:
            containerViewBottomConstraint?.update(offset: offset)
            view.layoutIfNeeded()
            
        case .ended, .cancelled:
            let shouldDismiss = offset > defaultHeight * 0.3 || velocity.y > 1200
            
            if shouldDismiss {
                animateDismiss()
            } else {
                containerViewBottomConstraint?.update(offset: 0)
                UIView.animate(
                    withDuration: 0.25,
                    delay: 0,
                    usingSpringWithDamping: configuration.springDamping,
                    initialSpringVelocity: configuration.springVelocity,
                    options: .curveEaseOut
                ) {
                    self.view.layoutIfNeeded()
                }
            }
            
        default:
            break
        }
    }
    
    @objc private func dimmedViewTapped() {
        animateDismiss()
    }
}
