//
//  Country.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 21.04.2022.
//

import Foundation

class Country: Feature<Country.Properties> {
    struct Properties: Codable {
        let id: String
        let name: String
    }
}
