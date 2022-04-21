//
//  RegionStateModel.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 20.04.2022.
//

import Foundation

struct RegionStateModel: Codable {
    let id: Int
    let name: String
    let name_en: String
    let alert: Bool
    let changed: Date
}
