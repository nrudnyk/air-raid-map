//
//  LandskapeOrientation.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 25.04.2022.
//

import SwiftUI

@propertyWrapper struct LandscapeOrientation: DynamicProperty {
    @StateObject private var orientationManager = OrientationManager.shared
    
    var wrappedValue: Bool {
        orientationManager.isLandscape
    }
}
