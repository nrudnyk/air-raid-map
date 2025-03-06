//
//  AlertStateModel.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 20.04.2022.
//

import Foundation
import Extensions

struct RegionStatesDecodable: Decodable {
    private enum CodingKeys: String, CodingKey {
        case lastUpdate = "last_update"
        case states = "states"
    }
    
    let lastUpdate: Date
    let regionStates: [RegionStateProperties]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let lastUpdateString = try container.decode(String.self, forKey: .lastUpdate)
        guard let date = DateFormatter.iso8601UTC.date(from: lastUpdateString)
        else {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: [CodingKeys.lastUpdate],
                debugDescription: "Date string looks to be invalid",
                underlyingError: nil
            ))
        }
        lastUpdate = date
        
        regionStates = try container.decode([RegionStateProperties].self, forKey: .states)
    }

    // TODO: Get rid of this, think about proper organization
    func alertState(for regionName: String) -> AlertState {
        if let regionState = regionStates.first(where: { regionName.contains($0.name) }) {
            return AlertState(
                type: regionState.alert ? .airAlarm : .allClear,
                changedAt: regionState.changed
            )
        }
        
        return AlertState()
    }
}

extension Array where Element == RegionState {
    func alertState(for regionName: String) -> AlertState {
        if let regionState = self.first(where: { regionName.contains($0.name) }) {
            return AlertState(
                type: regionState.alert ? .airAlarm : .allClear,
                changedAt: regionState.changed
            )
        }

        return AlertState()
    }
}
