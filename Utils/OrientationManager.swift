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
        
        NotificationCenter.default
            .publisher(for: UIDevice.orientationDidChangeNotification)
            .map { _ in UIDevice.current.orientation }
            .passthrough { [weak self] orientation in
                switch orientation {
                case .portrait, .portraitUpsideDown:
                    self?.isLandscape = false
                case .landscapeLeft, .landscapeRight:
                    self?.isLandscape = true
                default:
                    break
                }
            }
            .assign(to: &$type)
    }
}
