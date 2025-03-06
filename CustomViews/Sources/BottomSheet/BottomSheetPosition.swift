//
//  BottomSheetPosition.swift
//  air-raid-map (iOS)
//
//  Created by Nazar Rudnyk on 18.05.2022.
//

import Foundation
import CoreGraphics

public enum BottomSheetPosition: CGFloat, CaseIterable, Equatable {
    case top = 0.975
    case middle = 0.4
    case bottom = 0.125
    case hidden = 0
}
