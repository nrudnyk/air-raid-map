//
//  MapKitExtensions.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 14.05.2022.
//

#if !os(watchOS)

import MapKit

public extension MKMapView {
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

#endif
