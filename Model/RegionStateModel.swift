//
//  RegionStateModel.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 20.04.2022.
//

import MapKit

struct RegionStateModel: Identifiable {
    var id: String {
        return name
    }
    
    let id_0: Int
    let name: String
    let geometry: MKShape & MKGeoJSONObject
    let alertState: AlertState
}
