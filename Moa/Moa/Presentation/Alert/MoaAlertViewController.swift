//
//  MoaAlertViewController.swift
//  Moa
//
//  Created by 정도현 on 2/24/26.
//

import UIKit
import SnapKit

final class MoaAlertViewController: UIViewController {

    private let message: String

    private let dimView: UIView = {
        let v = UIView()
        v.backgroundColor = AppColor.Dim.primary
        return v
    }()

    private let alertView: UIView = {
        let v = UIView()
        v.backgroundColor = AppColor.Container.primary
        v.layer.cornerRadius = 16
        return v
    }()

    init(message: String) {
        self.message = message
        
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(dimView)
        view.addSubview(alertView)

        dimView.frame = view.bounds

        alertView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(280)
        }

        let label = UILabel()
        label.text = message
        label.font = AppTypography.b1_500.font()
        label.textColor = AppColor.IconAndText.highEmphasis
        label.textAlignment = .center
        label.numberOfLines = 0

        let button = UIButton(type: .system)
        button.setTitle("확인", for: .normal)
        button.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [label, button])
        stack.axis = .vertical
        stack.spacing = 20

        alertView.addSubview(stack)
        stack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(24)
        }
    }

    @objc private func dismissSelf() {
        dismiss(animated: true)
    }
}
