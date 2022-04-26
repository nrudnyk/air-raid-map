//
//  RegionsRepository.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 20.04.2022.
//

import MapKit

class RegionsRepository {
    public let regions: [Region] = RegionsRepository.getRegionsInfo()
    
    private static func getRegionsInfo() -> [Region] {
        do {
            let features = try RegionsRepository.decodeFeatures(Region.self, from: "regions", in: Bundle.main)
            return features
        } catch {
            print(error)
            return []
        }
    }
    
    private static func decodeFeatures<T: IDecodableGeoJSONFeature>(_ type: T.Type, from file: String, in bundle: Bundle) throws -> [T] {
        guard let url = bundle.url(forResource: file, withExtension: "geojson"),
              let geojsonData = try? Data(contentsOf: url),
              let decodedGeoJSON = try? MKGeoJSONDecoder().decode(geojsonData)
        else {
            throw GeoJSONError.invalidType
        }
        
        let features = try decodedGeoJSON
            .compactMap { $0 as? MKGeoJSONFeature }
            .map { try type.init(feature: $0) }
        
        return features
    }
}
