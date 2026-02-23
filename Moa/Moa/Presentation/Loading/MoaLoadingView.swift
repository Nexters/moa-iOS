//
//  MoaLoadingView.swift
//  Moa
//
//  Created by 정도현 on 2/23/26.
//

import UIKit
import Lottie
import SnapKit

final class MoaLoadingView: UIView {
    
    // MARK: - UI
    
    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.Dim.primary
        return view
    }()
    
    private let lottieView: LottieAnimationView = {
        let view = LottieAnimationView(name: "moa_loader")
        view.loopMode = .loop
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Setup
    
    private func setupUI() {
        addSubview(dimView)
        addSubview(lottieView)
        
        dimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        lottieView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(160)
        }
    }
    
    // MARK: - Control
    
    func start() {
        alpha = 0
        lottieView.play()
        UIView.animate(withDuration: 0.2) { self.alpha = 1 }
    }
    
    func stop(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }) { _ in
            self.lottieView.stop()
            completion?()
        }
    }
}
