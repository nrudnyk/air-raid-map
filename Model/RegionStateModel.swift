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
    let boudingRegion: MKMapRect
    
    init(region: Region, alertState: AlertState) {
        self.init(
            id: region.properties.ID_0,
            name: region.properties.NAME_1,
            geometry: region.geometry.first!,
            alertState: alertState
        )
    }
    
    init(id: Int = 0, name: String, geometry: MKShape & MKGeoJSONObject, alertState: AlertState) {
        self.id_0 = id
        self.name = name
        self.geometry = geometry
        self.alertState = alertState
        
        let overlay = geometry as! MKOverlay
        self.boudingRegion = overlay.boundingMapRect
    }
}
