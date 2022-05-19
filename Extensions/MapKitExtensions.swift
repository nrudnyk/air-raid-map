//
//  MapKitExtensions.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 14.05.2022.
//

import Foundation
import MapKit

extension MKMapView {
    static func mapRect(for region: MKCoordinateRegion) -> MKMapRect {
        let topLeft = CLLocationCoordinate2D(
            latitude: region.center.latitude + region.span.latitudeDelta / 2,
            longitude: region.center.longitude - region.span.longitudeDelta / 2
        )
        let bottomRight = CLLocationCoordinate2D(
            latitude: region.center.latitude - region.span.latitudeDelta / 2,
            longitude: region.center.longitude + region.span.longitudeDelta / 2
        )
        
        let a = MKMapPoint(topLeft)
        let b = MKMapPoint(bottomRight)
        
        return MKMapRect(
            origin: MKMapPoint(
                x: min(a.x, b.x),
                y: min(a.y, b.y)
            ),
            size: MKMapSize(
                width: abs(a.x - b.x),
                height: abs(a.y - b.y)
            )
        )
    }
    
    func setCoordinateRegion(_ region: MKCoordinateRegion, edgePadding: PlatformEdgeInsets = .zero, animated: Bool = true) {
        let mapRect = MKMapView.mapRect(for: region)
        
        self.setVisibleMapRect(mapRect, edgePadding: edgePadding, animated: animated)
    }
}

extension MKCoordinateRegion: Equatable {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        return
            lhs.center.latitude == rhs.center.latitude &&
            lhs.center.longitude == rhs.center.longitude &&
            lhs.span.latitudeDelta == rhs.span.latitudeDelta &&
            lhs.span.longitudeDelta == rhs.span.longitudeDelta
    }
}

extension MKMapRect: Equatable {
    public static func == (lhs: MKMapRect, rhs: MKMapRect) -> Bool {
        return
            lhs.origin.x == rhs.origin.x &&
            lhs.origin.y == rhs.origin.y &&
            lhs.size.width == rhs.size.width &&
            lhs.size.height == rhs.size.height
    }
}
