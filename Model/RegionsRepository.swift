//
//  RegionsRepository.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 20.04.2022.
//

import MapKit

class RegionsRepository {
    
    public let regions: [Int: RegionModel]
    
    init() {
        self.regions = RegionsRepository.getRegionsInfo()
    }
    
    private static func getRegionsInfo() -> [Int: RegionModel] {
        guard let jsonData = RegionsRepository.getLocalGeoJSON(fileName: "regions") else { return [:] }
              
        do {
            let features = try MKGeoJSONDecoder()
                .decode(jsonData)
                .compactMap { $0 as? MKGeoJSONFeature }
            
            return features
                .compactMap(RegionModel.init)
                .toDictionary { $0.fid }
            
        } catch {
            print("Couldn't parse geojson, unexpected error: \(error)")
        }
        
        return [:]
    }
    
    private static func getLocalGeoJSON(fileName: String) -> Data? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "geojson"),
              let jsonData = try? Data(contentsOf: url)
        else {
            return nil
        }

        return jsonData
    }
}
