//
//  Region.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 20.04.2022.
//

import MapKit

class Region: Feature<Region.Properties> {
    struct Properties: Codable {
        let ID_0: Int
        let ISO: String
        let NAME_0: String
        let ID_1: Int
        let NAME_1: String
        let VARNAME_1: String
        let NL_NAME_1: String
        let HASC_1: String
        let CC_1: String
        let TYPE_1: String
        let ENGTYPE_1: String
    }
}
