//
//  Feature.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 21.04.2022.
//

import MapKit

class Feature<Properties: Decodable>: NSObject, IDecodableGeoJSONFeature {
    let properties: Properties
    let geometry: [MKShape & MKGeoJSONObject]
    
    required init(feature: MKGeoJSONFeature) throws {
        if let data = feature.properties {
            let decoder = JSONDecoder()
            
            do {
                properties = try decoder.decode(Properties.self, from: data)
            } catch {
                print(error)
                throw GeoJSONError.invalidData
            }
        } else {
            throw GeoJSONError.invalidData
        }
        
        geometry = feature.geometry
        
        super.init()
    }
}
