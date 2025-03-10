//
//  NotificationCenter+Extensions.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 04.07.2022.
//

#if os(iOS)

import UIKit
import Combine

public extension NotificationCenter {
    func appForegroundStatePublisher() -> AnyPublisher<Bool, Never> {
        return Publishers.Merge(
            NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification).map { _ in false },
            NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification).map { _ in true }
        )
        .eraseToAnyPublisher()
    }
}

extension UIImage: Identifiable {
    public var id: Int { return self.hash }
}

#endif
