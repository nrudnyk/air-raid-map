//
//  TabType.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 16.07.2022.
//

import SwiftUI

enum TabType: Int {
    case map
    case regions

    var icon: Image {
        switch self {
        case .map: return Image(systemName: "map")
        case .regions: return Image(systemName: "list.bullet.below.rectangle")
        }
    }

    var iconName: String {
        switch self {
        case .map: return "map"
        case .regions: return "list.bullet.below.rectangle"
        }
    }

    var localizedTitle: String {
        switch self {
        case .map: return "map".localized
        case .regions: return "regions".localized
        }
    }
}
