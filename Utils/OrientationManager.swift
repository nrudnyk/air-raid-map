//
//  OrientationManager.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 24.04.2022.
//

import Foundation
import SwiftUI
import Combine

class OrientationManager: ObservableObject {
    static let shared = OrientationManager()
    
    @Published var isLandscape: Bool = false
    @Published var type: UIDeviceOrientation = .unknown
    
    init() {
        guard let scene = UIApplication.shared.connectedScenes.first,
              let sceneDelegate = scene as? UIWindowScene
        else { return }
        
        let orientation = sceneDelegate.interfaceOrientation
        switch orientation {
            case .portrait: type = .portrait
            case .portraitUpsideDown: type = .portraitUpsideDown
            case .landscapeLeft: type = .landscapeLeft
            case .landscapeRight: type = .landscapeRight
                
            default: type = .unknown
        }
        tryUpdateIsLandscape(orientation: type)
        
        NotificationCenter.default
            .publisher(for: UIDevice.orientationDidChangeNotification)
            .map { _ in UIDevice.current.orientation }
            .passthrough(tryUpdateIsLandscape(orientation:))
            .assign(to: &$type)
    }
    
    private func tryUpdateIsLandscape(orientation: UIDeviceOrientation) {
        switch orientation {
        case .portrait, .portraitUpsideDown:
            isLandscape = false
        case .landscapeLeft, .landscapeRight:
            isLandscape = true
        default:
            break
        }
    }
}
