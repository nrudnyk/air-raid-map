//
//  Feature.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 21.04.2022.
//

import MapKit

class Feature<Properties: Decodable>: NSObject, IDecodableGeoJSONFeature {
    let id: Int
    let properties: Properties
    let geometry: [MKShape & MKGeoJSONObject]
    
    required init(feature: MKGeoJSONFeature) throws {
        guard let id = feature.identifier else {
            throw GeoJSONError.invalidData
        }
        if let identifier = Int(id) {
            self.id = identifier
        } else {
            throw GeoJSONError.invalidData
        }

        if let data = feature.properties {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            properties = try decoder.decode(Properties.self, from: data)
        } else {
            throw GeoJSONError.invalidData
        }
        
        geometry = feature.geometry
        
        super.init()
    }
}
