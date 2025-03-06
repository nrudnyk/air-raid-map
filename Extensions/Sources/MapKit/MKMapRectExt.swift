//
//  MapKitExtensions.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 14.05.2022.
//

import MapKit

extension MKMapRect: Equatable {
    public static func == (lhs: MKMapRect, rhs: MKMapRect) -> Bool {
        return
            lhs.origin.x == rhs.origin.x &&
            lhs.origin.y == rhs.origin.y &&
            lhs.size.width == rhs.size.width &&
            lhs.size.height == rhs.size.height
    }
}
