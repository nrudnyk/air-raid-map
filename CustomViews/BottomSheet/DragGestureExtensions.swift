//
//  DragGestureExtensions.swift
//  air-raid-map (iOS)
//
//  Created by Nazar Rudnyk on 18.05.2022.
//

import SwiftUI

internal extension DragGesture {
    enum DragState {
        case none
        case changed(value: DragGesture.Value)
        case ended(value: DragGesture.Value)
    }
}
