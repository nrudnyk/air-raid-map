//
//  Orientation.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 25.04.2022.
//

import SwiftUI

@propertyWrapper struct Orientation: DynamicProperty {
    @StateObject private var orientationManager = OrientationManager.shared
    
    var wrappedValue: UIDeviceOrientation {
        orientationManager.type
    }
}
