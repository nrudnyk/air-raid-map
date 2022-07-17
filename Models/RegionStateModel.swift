//
//  RegionStateModel.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 20.04.2022.
//

import MapKit

struct RegionStateModel: Identifiable, Equatable, Hashable {
    var id: String {
        return nameKey
    }
    
    let id_0: Int
    let nameKey: String
    let geometry: MKShape & MKGeoJSONObject
    let alertState: AlertState
    let boudingRegion: MKMapRect
    
    init(region: Region, alertState: AlertState) {
        self.init(
            id: region.properties.ID_0,
            nameKey: region.properties.NAME_ENG_1,
            geometry: region.geometry.first!,
            alertState: alertState
        )
    }
    
    init(id: Int = 0, nameKey: String, geometry: MKShape & MKGeoJSONObject, alertState: AlertState) {
        self.id_0 = id
        self.nameKey = nameKey
        self.geometry = geometry
        self.alertState = alertState
        
        let overlay = geometry as! MKOverlay
        self.boudingRegion = overlay.boundingMapRect
    }

    static func == (lhs: RegionStateModel, rhs: RegionStateModel) -> Bool {
        return
            lhs.id == rhs.id &&
            lhs.geometry == rhs.geometry &&
            lhs.alertState.type == rhs.alertState.type
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(nameKey)
        hasher.combine(geometry)
        hasher.combine(alertState.type)
    }
}
