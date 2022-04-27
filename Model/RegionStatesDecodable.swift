//
//  AlertStateModel.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 20.04.2022.
//

import Foundation

struct RegionStatesDecodable: Decodable {
    private enum CodingKeys: String, CodingKey {
        case lastUpdate = "last_update"
        case states = "states"
    }
    
    private struct RegionDecodable: Decodable {
        let id: Int
        let name: String
        let name_en: String
        let alert: Bool
        let changed: String
    }
    
    let lastUpdate: Date
    private let regionStates: [RegionDecodable]
    
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
        
        regionStates = try container.decode([RegionDecodable].self, forKey: .states)
    }
    
    func alertState(for region: Region) -> AlertState {
        if let regionState = regionStates.first(where: { region.properties.NAME_1.contains($0.name) }) {
            return AlertState(
                type: regionState.alert ? .airAlarm : .allClear,
                changedAt: DateFormatter.iso8601Full.date(from: regionState.changed)!
            )
        }
        
        return AlertState()
    }
}
