//
//  LoginViewController.swift
//  Moa
//
//  Created by mirim on 1/28/26.
//

import UIKit
import SnapKit
import AuthenticationServices

final class LoginViewController: BaseViewController {
    
    // MARK: - Constants
    
    private enum Constant {
        static let loginWithKakaoTalk = "카카오로 계속하기"
        static let loginWithApple = "Apple로 계속하기"
    }
    
    // MARK: - Dependencies
    
    private let viewModel: LoginViewModel
    private weak var router: AppRouting?
    
    // MARK: - UI Components
    
    private let logoImageView = LogoImageView()
    private let loginButtonStackView: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.spacing = 12.0
        v.alignment = .fill
        v.distribution = .fill
        return v
    }()
    
    private let kakaoLoginButton = AppButton()
    private let appleLoginButton = AppButton()
    
    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPage = 0
        pc.numberOfPages = 3
        pc.hidesForSinglePage = true
        pc.pageIndicatorTintColor = .lightGray
        pc.currentPageIndicatorTintColor = .darkGray
        // pageControl.isUserInteractionEnabled = false
        return pc
    }()
    
    // MARK: - Pager Components
    private let pagerScrollView = UIScrollView()
    private let pagerContentView = UIStackView()

    private var autoPagingTimer: Timer?
    private var resumeTimer: Timer?
    private var currentPage: Int = 0
    private let numberOfPages = 3
    
    // MARK: - Init
    
    init(viewModel: LoginViewModel, router: AppRouting) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    override func setupUI() {
        view.addSubview(logoImageView)
        view.addSubview(loginButtonStackView)
        
        loginButtonStackView.addArrangedSubview(kakaoLoginButton)
        loginButtonStackView.addArrangedSubview(appleLoginButton)
        
        logoImageView.snp.makeConstraints { make in
            make.height.lessThanOrEqualTo(logoImageView.snp.width).multipliedBy(0.8)
        }
        
        [kakaoLoginButton, appleLoginButton].forEach { $0.snp.makeConstraints { $0.height.equalTo(64) } }
        
        loginButtonStackView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
        }
        
        pagerScrollView.isPagingEnabled = true
        pagerScrollView.showsHorizontalScrollIndicator = false
        pagerScrollView.showsVerticalScrollIndicator = false
        pagerScrollView.delegate = self
        pagerScrollView.clipsToBounds = true

        pagerContentView.axis = .horizontal
        pagerContentView.alignment = .fill
        pagerContentView.distribution = .fillEqually
        pagerContentView.spacing = 0

        view.addSubview(pagerScrollView)
        pagerScrollView.addSubview(pagerContentView)

        pagerScrollView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(view.snp.height).multipliedBy(0.6)
        }

        pagerContentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }

        let firstGuidePage = UIView()
        firstGuidePage.backgroundColor = .clear
        let secondGuidePage = UIView()
        secondGuidePage.backgroundColor = .systemGray3
        let thirdGuidePage = UIView()
        thirdGuidePage.backgroundColor = .systemGray5
        
        firstGuidePage.addSubview(logoImageView)
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.lessThanOrEqualTo(firstGuidePage.snp.height).multipliedBy(0.8)
        }
        
        let secondLabel = UILabel()
        secondLabel.text = "페이지 2"
        secondLabel.textAlignment = .center
        secondGuidePage.addSubview(secondLabel)
        secondLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        let thirdLabel = UILabel()
        thirdLabel.text = "페이지 3"
        thirdLabel.textAlignment = .center
        thirdGuidePage.addSubview(thirdLabel)
        thirdLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        pagerContentView.addArrangedSubview(firstGuidePage)
        pagerContentView.addArrangedSubview(secondGuidePage)
        pagerContentView.addArrangedSubview(thirdGuidePage)

        pagerContentView.snp.makeConstraints { make in
            make.width.equalTo(pagerScrollView.snp.width).multipliedBy(numberOfPages)
        }
        
        view.addSubview(pageControl)
        pageControl.snp.makeConstraints { make in
            make.top.equalTo(pagerScrollView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        applyPageControlAppearance()
        
        loginButtonStackView.snp.remakeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.top.greaterThanOrEqualTo(pageControl.snp.bottom).offset(16)
        }
        
        kakaoLoginButton.setTitle(Constant.loginWithKakaoTalk, for: .normal)
        kakaoLoginButton.applyStyle(.init(
            enabled: .init(
                backgroundColor: .yellow,
                text: .init(font: AppTypography.t3_700.font(), color: AppColor.IconAndText.highEmphasisReverse)),
            pressed: .init(
                backgroundColor: .yellow,
                text: .init(font: AppTypography.t3_700.font(), color: AppColor.IconAndText.highEmphasisReverse)),
            disabled: .init(
                backgroundColor: .yellow,
                text: .init(font: AppTypography.t3_700.font(), color: AppColor.IconAndText.highEmphasisReverse)),
            cornerRadius: 32,
            verticalPadding: 19,
            image: UIImage(resource: .Icon.iconKakaotalk)
        ))
        
        appleLoginButton.setTitle(Constant.loginWithApple, for: .normal)
        appleLoginButton.applyStyle(.tertiary(image: UIImage(resource: .Icon.iconApple)))
    }
    
    override func bind() {
        bindOutput(viewModel.outputs) { [weak router] output in
            switch output {
            case .loginSucceed:
                router?.navigate(to: .onboarding, animated: true)
            case .loginFailed:
                break // TODO: 로그인 실패 처리
            }
        }
    }
    
    override func setupActions() {
        kakaoLoginButton.addTarget(self, action: #selector(didTapKakao), for: .touchUpInside)
        appleLoginButton.addTarget(self, action: #selector(didTapApple), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAutoPaging()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAutoPaging()
        resumeTimer?.invalidate()
        resumeTimer = nil
    }
    
    @objc private func didTapKakao() {
        viewModel.didTapLoginWithKakaoTalk()
    }
    
    @objc private func didTapApple() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    // MARK: - Auto Paging Control
    private func startAutoPaging() {
        stopAutoPaging()
        autoPagingTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.goToNextPage(animated: true)
        }
        if let timer = autoPagingTimer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }

    private func stopAutoPaging() {
        autoPagingTimer?.invalidate()
        autoPagingTimer = nil
    }

    private func scheduleResumeAutoPaging() {
        resumeTimer?.invalidate()
        resumeTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.goToNextPage(animated: true)
            self.startAutoPaging()
        }
        
        if let timer = resumeTimer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }

    private func goToNextPage(animated: Bool) {
        guard numberOfPages > 0 else { return }
        currentPage = (currentPage + 1) % numberOfPages
        scrollToPage(index: currentPage, animated: animated)
        pageControl.currentPage = currentPage
        updatePageControlIndicatorImages()
    }

    private func scrollToPage(index: Int, animated: Bool) {
        let pageWidth = pagerScrollView.bounds.width
        let offsetX = CGFloat(index) * pageWidth
        pagerScrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: animated)
    }
    
    private func applyPageControlAppearance() {
        pageControl.pageIndicatorTintColor = AppColor.IconAndText.disabled
        pageControl.currentPageIndicatorTintColor = AppColor.IconAndText.highEmphasis
        updatePageControlIndicatorImages()
    }

    private func updatePageControlIndicatorImages() {
        let selectedColor = AppColor.IconAndText.highEmphasis
        let deselectedColor = AppColor.IconAndText.disabled

        let selectedImage = makeIndicatorImage(size: CGSize(width: 16, height: 8), color: selectedColor, cornerRadius: 4)
        let deselectedImage = makeIndicatorImage(size: CGSize(width: 8, height: 8), color: deselectedColor, cornerRadius: 4)

        for index in 0..<pageControl.numberOfPages {
            if #available(iOS 16.0, *) {
                let image = (index == pageControl.currentPage) ? selectedImage : deselectedImage
                pageControl.setIndicatorImage(image, forPage: index)
            }
        }
    }

    private func makeIndicatorImage(size: CGSize, color: UIColor, cornerRadius: CGFloat) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let rect = CGRect(origin: .zero, size: size)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
            color.setFill()
            path.fill()
        }.withRenderingMode(.alwaysOriginal)
    }
}

// MARK: - SignIn with Apple Delegate

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        self.view.window ?? UIWindow()
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        print("애플로 로그인 실패")
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIdCredential as ASAuthorizationAppleIDCredential:
            let idToken = appleIdCredential.identityToken
            
            if let idToken,
               let idTokenString = String(data: idToken, encoding: .utf8) {
                viewModel.didReceiveInfoFromApple(idToken: idTokenString)
            } else {
                print("토큰 변환 실패")
            }
            
        default:
            break
        }
    }
}

// MARK: - UIScrollViewDelegate

extension LoginViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopAutoPaging()
        resumeTimer?.invalidate()
        resumeTimer = nil
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCurrentPageFromOffset()
        scheduleResumeAutoPaging()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            updateCurrentPageFromOffset()
            scheduleResumeAutoPaging()
        }
    }
    
    private func updateCurrentPageFromOffset() {
        let pageWidth = pagerScrollView.bounds.width
        if pageWidth > 0 {
            let page = Int(round(pagerScrollView.contentOffset.x / pageWidth))
            currentPage = max(0, min(numberOfPages - 1, page))
            pageControl.currentPage = currentPage
            updatePageControlIndicatorImages()
        }
    }
}

