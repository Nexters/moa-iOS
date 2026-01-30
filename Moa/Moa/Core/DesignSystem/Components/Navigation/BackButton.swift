//
//  BackButton.swift
//  Moa
//
//  Created by mirim on 1/30/26.
//

import UIKit

final class BackButton: UIButton {
    struct Style {
        var imageResource: ImageResource
        var hitAreaInset: UIEdgeInsets
        var contentInset: NSDirectionalEdgeInsets
        
        static func `default`() -> Style {
            .init(
                imageResource: .Icon.iconNavBack,
                hitAreaInset: .init(top: -10, left: -10, bottom: -10, right: -10),
                contentInset: .init(top: 8, leading: 0, bottom: 8, trailing: 0)
            )
        }
    }
    
    private let style: Style
    
    init(style: Style = .default()) {
        self.style = style
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) { nil }
    
    private func configure() {
        var config = UIButton.Configuration.plain()
        config.contentInsets = style.contentInset
        let img = UIImage(resource: style.imageResource)
        config.image = img.withRenderingMode(.alwaysOriginal)
        self.configuration = config
    }
    
    // 터치 영역 확장
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let enlargedBounds = bounds.inset(by: style.hitAreaInset)
        return enlargedBounds.contains(point)
    }
}
