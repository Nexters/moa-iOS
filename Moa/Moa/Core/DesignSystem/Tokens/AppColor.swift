//
//  AppColor.swift
//  Moa
//
//  Created by mirim on 1/25/26.
//

import UIKit

/*
 UI에서 직접 팔레트를 사용하지 않고, Semantic에 기반한 색상 사용
 화면/컴포넌트에서 App.Color.*만 사용하고, 내부 구현(Palette)은 직접 참조하지 않음
 실제 색상 값은 하단의 Palette에서 관리되며, 디자인 변경시 매핑만 수정
 */

enum AppColor {
    enum Background {
        static let primary = Palette.Grayscale.gray90
        static let secondary = Palette.Grayscale.gray80
    }
    
    enum Container {
        static let primary = Palette.Grayscale.gray80
        static let secondary = Palette.Grayscale.gray70
    }
    
    enum IconAndText {
        static let highEmphasis = Palette.Grayscale.gray0
        static let mediumEmphasis = Palette.Grayscale.gray0.withAlphaComponent(0.6)
        static let lowEmphasis = Palette.Grayscale.gray0.withAlphaComponent(0.4)
        static let disabled = Palette.Grayscale.gray0.withAlphaComponent(0.28)
        static let highEmphasisReverse = Palette.Grayscale.gray90
        static let error = Palette.Semantic.error
        static let errorLight = Palette.Semantic.errorLight
        static let green = Palette.Primary.green40
        static let blue = Palette.Secondary.blue
        static let blueLight = Palette.Secondary.blueLight
    }
    
    enum Divider {
        static let primary = Palette.Grayscale.gray80
        static let secondary = Palette.Grayscale.gray70
    }
    
    enum Dim {
        static let primary = Palette.Dim.dark
        static let secondary = Palette.Dim.light
    }
    
    enum Btn {
        enum Primary {
            static let enable = Palette.Primary.green40
            static let pressed = Palette.Primary.green50
            static let disabled = Palette.Grayscale.gray70
        }
        
        enum Secondary {
            static let enable = Palette.Grayscale.gray60
            static let pressed = Palette.Grayscale.gray70
            static let disabled = Palette.Grayscale.gray70
        }
        
        enum Tertiary {
            static let enable = Palette.Grayscale.gray0
            static let pressed = Palette.Grayscale.gray20
            static let disabled = Palette.Grayscale.gray70
        }
    }
}

// MARK: - Assets의 Color를 코드 상수로 매핑한 값들
private extension AppColor {
    enum Palette {
        enum Dim {
            static let dark = UIColor(resource: .Color.Dim.dark)
            static let light = UIColor(resource: .Color.Dim.light)
        }
        
        enum Grayscale {
            static let gray0 = UIColor(resource: .Color.Grayscale.gray0)
            static let gray10 = UIColor(resource: .Color.Grayscale.gray10)
            static let gray20 = UIColor(resource: .Color.Grayscale.gray20)
            static let gray30 = UIColor(resource: .Color.Grayscale.gray30)
            static let gray40 = UIColor(resource: .Color.Grayscale.gray40)
            static let gray50 = UIColor(resource: .Color.Grayscale.gray50)
            static let gray60 = UIColor(resource: .Color.Grayscale.gray60)
            static let gray70 = UIColor(resource: .Color.Grayscale.gray70)
            static let gray80 = UIColor(resource: .Color.Grayscale.gray80)
            static let gray90 = UIColor(resource: .Color.Grayscale.gray90)
        }
        
        enum Primary {
            static let green10 = UIColor(resource: .Color.Primary.green10)
            static let green20 = UIColor(resource: .Color.Primary.green20)
            static let green30 = UIColor(resource: .Color.Primary.green30)
            static let green40 = UIColor(resource: .Color.Primary.green40)
            static let green50 = UIColor(resource: .Color.Primary.green50)
            static let green60 = UIColor(resource: .Color.Primary.green60)
            static let green70 = UIColor(resource: .Color.Primary.green70)
        }
        
        enum Secondary {
            static let blueLight = UIColor(resource: .Color.Secondary.blueLight)
            static let blue = UIColor(resource: .Color.Secondary.blue)
            static let pinkLight = UIColor(resource: .Color.Secondary.pinkLight)
            static let pink = UIColor(resource: .Color.Secondary.pink)
            static let yellowLight = UIColor(resource: .Color.Secondary.yellowLight)
            static let yellow = UIColor(resource: .Color.Secondary.yellow)
        }
        
        enum Semantic {
            static let errorLight = UIColor(resource: .Color.Semantic.errorLight)
            static let error = UIColor(resource: .Color.Semantic.error)
        }
    }
}
