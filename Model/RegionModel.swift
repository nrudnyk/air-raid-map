//
//  RegionModel.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 20.04.2022.
//

import MapKit

struct RegionModel {
    let fid: Int
    let name: String
    let geometry: [MKShape & MKGeoJSONObject]
    
    init?(feature: MKGeoJSONFeature) {
        self.geometry = feature.geometry
         
        guard let data = feature.properties,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return nil
        }
        
        self.fid = json["fid"] as! Int
        self.name = json["region"] as! String
    }
}
