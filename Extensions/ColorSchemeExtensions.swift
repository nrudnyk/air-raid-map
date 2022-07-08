//
//  ColorSchemeExtensions.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 08.07.2022.
//

import SwiftUI

extension ColorScheme {
#if os(iOS)
    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .light: return .light
        case .dark: return .dark
        @unknown default: return .unspecified
        }
    }
#elseif os(macOS)
    var appearance: NSAppearance? {
        switch self {
        case .light: return NSAppearance(named: .aqua)
        case .dark: return NSAppearance(named: .darkAqua)
        @unknown default: return NSAppearance(named: .aqua)
        }
    }
#endif
}
