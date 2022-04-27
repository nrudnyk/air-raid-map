//
//  RegionStateModel.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 20.04.2022.
//

import MapKit

struct RegionStateModel: Identifiable {
    let id: Int
    let name: String
    let geometry: MKShape & MKGeoJSONObject
    let alertState: AlertState
}
