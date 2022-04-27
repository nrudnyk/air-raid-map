//
//  MapContants.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 25.04.2022.
//

import MapKit

public enum MapConstsants {
    public static let centerOfUkraine = CLLocationCoordinate2DMake(48.84964001422709, 31.18144598789513)
    public static let boundsOfUkraine = MKCoordinateRegion(
        center: centerOfUkraine,
        span: MKCoordinateSpan(latitudeDelta: 7.327285995706916 + 1, longitudeDelta: 18.0914518609643 + 1)
    )
}
