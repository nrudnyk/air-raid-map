//
//  AlertStateModel.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 20.04.2022.
//

import Foundation

struct AlertStateModel: Codable {
    var states: [RegionStateModel]
    var last_update: String
}
