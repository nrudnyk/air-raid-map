//
//  MapKitExtensions.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 14.05.2022.
//

import MapKit

extension MKCoordinateRegion: Equatable {
    func withVerticalPadding(_ coef: CGFloat) -> MKCoordinateRegion {
        let verticalSpan = self.span.latitudeDelta
        let additionalSpan = verticalSpan * coef
        let newRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: self.center.latitude - additionalSpan,
                longitude: self.center.longitude
            ),
            span: MKCoordinateSpan(
                latitudeDelta: verticalSpan + additionalSpan,
                longitudeDelta: self.span.longitudeDelta
            )
        )

        return newRegion
    }

    func withHorizontalPadding(_ coef: CGFloat) -> MKCoordinateRegion {
        let horizontalSpan = self.span.longitudeDelta
        let additionalSpan = horizontalSpan * coef
        let newRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: self.center.latitude,
                longitude: self.center.longitude - additionalSpan
            ),
            span: MKCoordinateSpan(
                latitudeDelta: self.span.latitudeDelta,
                longitudeDelta: horizontalSpan + additionalSpan * 2
            )
        )

        return newRegion
    }

    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        return
            lhs.center.latitude == rhs.center.latitude &&
            lhs.center.longitude == rhs.center.longitude &&
            lhs.span.latitudeDelta == rhs.span.latitudeDelta &&
            lhs.span.longitudeDelta == rhs.span.longitudeDelta
    }
}
