//
//  UIApplicationExtensions.swift
//  air-raid-map (iOS)
//
//  Created by Nazar Rudnyk on 18.05.2022.
//

#if os(iOS)

import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#endif
