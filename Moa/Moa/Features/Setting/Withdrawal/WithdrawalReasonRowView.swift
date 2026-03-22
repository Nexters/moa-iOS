//
//  WithdrawalReasonRowView.swift
//  Moa
//
//  Created by mirim on 2/24/26.
//

import UIKit
import SnapKit

final class WithdrawalReasonRowView: UIView {
    
    // MARK: - Properties
    
    var onTap: (() -> Void)?
    
    var isSelected: Bool = false {
        didSet { updateCheckboxState() }
    }
    
    // MARK: - UI Components
    
    private lazy var checkImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(resource: isSelected ? .Icon.iconCheckRectangleSelected : .Icon.iconCheckRectangleUnselected)
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let titleLabel: StyledLabel = {
        let label = StyledLabel()
        label.setStyle(.init(
            typography: AppTypography.b1_500,
            color: AppColor.IconAndText.highEmphasis
        ))
        return label
    }()
    
    private let rowStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        return stack
    }()
    
    // MARK: - Init
    
    init(title: String) {
        super.init(frame: .zero)
        titleLabel.setText(title)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        rowStack.addArrangedSubViews([checkImageView, titleLabel])
        addSubview(rowStack)
        
        checkImageView.snp.makeConstraints { make in
            make.width.height.equalTo(32)
        }
        checkImageView.setContentHuggingPriority(.required, for: .horizontal)
        checkImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        rowStack.snp.makeConstraints { make in
//            make.leading.trailing.equalToSuperview()
//            make.top.bottom.equalToSuperview().inset(12)
            make.edges.equalToSuperview()
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }
    
    private func updateCheckboxState() {
        let image = isSelected
            ? UIImage(resource: .Icon.iconCheckRectangleSelected)
            : UIImage(resource: .Icon.iconCheckRectangleUnselected)
        
        UIView.animate(withDuration: 0.15) {
            self.checkImageView.image = image
        }
    }
    
    func toggle() {
        isSelected.toggle()
    }
    
    @objc private func handleTap() {
        onTap?()
    }
}
