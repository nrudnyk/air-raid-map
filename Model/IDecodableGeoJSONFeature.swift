//
//  IDecodableGeoJSONFeature.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 21.04.2022.
//

import MapKit

protocol IDecodableGeoJSONFeature {
    init(feature: MKGeoJSONFeature) throws
}
