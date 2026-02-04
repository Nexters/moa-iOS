//
//  IconTextView.swift
//  Moa
//
//  Created by 정도현 on 2/4/26.
//

import UIKit
import SnapKit

enum IconTextViewType {
    case date
    case location

    var icon: UIImage? {
        switch self {
        case .date:
            return UIImage(resource: .Icon.iconClock)
        case .location:
            return UIImage(resource: .Icon.iconLocationPin)
        }
    }
}

/// Icon + Text를 갖는 형태의 뷰 입니다.
final class IconTextView: UIView {
    
    // MARK: - Properties
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = AppColor.IconAndText.mediumEmphasis
        return imageView
    }()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = AppTypography.b2_400.font()
        label.textColor = AppColor.IconAndText.highEmphasis
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [iconImageView, textLabel])
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .center
        return stackView
    }()
    
    // MARK: - Init
    init(type: IconTextViewType, text: String) {
        super.init(frame: .zero)
        
        setupUI()
        configure(type: type, text: text)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        addSubview(stackView)
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints {
            $0.width.height.equalTo(16)
        }
        
        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    // MARK: - Configuration
    func configure(type: IconTextViewType, text: String) {
        iconImageView.image = type.icon?.withRenderingMode(.alwaysTemplate)
        textLabel.text = text
    }
}
