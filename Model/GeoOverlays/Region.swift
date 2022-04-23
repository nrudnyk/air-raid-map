//
//  Region.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 20.04.2022.
//

import MapKit

class Region: Feature<Region.Properties> {
    struct Properties: Codable {
        let fid: Int
        let region: String
    }
}
