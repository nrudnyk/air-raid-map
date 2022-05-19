//
//  BottomSheet.swift
//  air-raid-map (iOS)
//
//  Created by Nazar Rudnyk on 18.05.2022.
//

import SwiftUI

public struct BottomSheet {
    static var widthFraction: CGFloat {
        return OrientationManager.shared.isLandscape ? 1.0 / 7 * 3 : 1
    }
    ///The options to adjust the behavior and the settings of the BottomSheet.
    public enum Options: Equatable {
        public static func == (lhs: BottomSheet.Options, rhs: BottomSheet.Options) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
        
        ///Sets the animation for opening and closing the BottomSheet.
        case animation(Animation)
        ///Changes the background of the BottomSheet. Must be erased to AnyView.
        case background(() -> AnyView)
        ///Enables and sets the blur effect of the background when pulling up the BottomSheet.
        case backgroundBlur(effect: UIBlurEffect.Style = .systemUltraThinMaterial)
        ///Changes the corner radius of the BottomSheet.
        case cornerRadius(Double)
        ///Adds a shadow to the background of the BottomSheet.
        case shadow(color: Color = Color(.sRGBLinear, white: 0, opacity: 0.33), radius: CGFloat = 10, x: CGFloat = 0, y: CGFloat = 0)
        
        var rawValue: String {
            switch self {
            case .animation:
                return "animation"
            case .background:
                return "background"
            case .backgroundBlur:
                return "backgroundBlur"
            case .cornerRadius:
                return "cornerRadius"
            case .shadow:
                return "shadow"
            }
        }
    }
}

internal extension Array where Element == BottomSheet.Options {
    var animation: Animation {
        var animation: Animation = Animation.spring(response: 0.5, dampingFraction: 0.75, blendDuration: 1)
        
        self.forEach { item in
            if case .animation(let customAnimation) = item {
                animation = customAnimation
            }
        }
        
        return animation
    }
    
    var backgroundBlurEffect: UIBlurEffect {
        var blurEffect: UIBlurEffect = UIBlurEffect(style: .systemThinMaterial)
        
        self.forEach { item in
            if case .backgroundBlur(let customBlurEffect) = item {
                blurEffect = UIBlurEffect(style: customBlurEffect)
            }
        }
        
        return blurEffect
    }
    
    var cornerRadius: CGFloat {
        var cornerRadius: CGFloat = 10.0
        
        self.forEach { item in
            if case .cornerRadius(let customCornerRadius) = item {
                cornerRadius = CGFloat(customCornerRadius)
            }
        }
        
        return cornerRadius
    }
    
    var shadowColor: Color {
        var shadowColor: Color = .clear
        
        self.forEach { item in
            if case .shadow(color: let customShadowColor, radius: _, x: _, y: _) = item {
                shadowColor = customShadowColor
            }
        }
        
        return shadowColor
    }
    
    var shadowRadius: CGFloat {
        var shadowRadius: CGFloat = 0
        
        self.forEach { item in
            if case .shadow(color: _, radius: let customShadowRadius, x: _, y: _) = item {
                shadowRadius = customShadowRadius
            }
        }
        
        return shadowRadius
    }
    
    var shadowX: CGFloat {
        var shadowX: CGFloat = 0
        
        self.forEach { item in
            if case .shadow(color: _, radius: _, x: let customShadowX, y: _) = item {
                shadowX = customShadowX
            }
        }
        
        return shadowX
    }
    
    var shadowY: CGFloat {
        var shadowY: CGFloat = 0
        
        self.forEach { item in
            if case .shadow(color: _, radius: _, x: _, y: let customShadowY) = item {
                shadowY = customShadowY
            }
        }
        
        return shadowY
    }
}
