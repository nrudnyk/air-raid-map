//
//  StubAirAlertsDataService.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 11.05.2022.
//

import Foundation
import Combine
import OSLog

class StubAirAlertsDataService: IAirAlertsDataService {

    func getData() -> AnyPublisher<[RegionStateProperties], Error> {
        guard let url = Bundle.main.url(forResource: "test-sirens", withExtension: "json"),
              let jsonData = try? Data(contentsOf: url)
        else {
            return Fail(error: GeoJSONError.invalidType)
                .eraseToAnyPublisher()
        }
        
        return Just(jsonData)
            .decode(type: RegionStatesDecodable.self, decoder: JSONDecoder())
            .map { regionsDecodable in
                UserDefaults.standard.set(
                    DateFormatter.localizedString(from: regionsDecodable.lastUpdate, dateStyle: .medium, timeStyle: .medium),
                    forKey: UserDefaults.Keys.lastUpdate
                )
                return regionsDecodable.regionStates
            }
            .eraseToAnyPublisher()
    }

    func getHistoryData() -> AnyPublisher<[AirAlertStateProperties], Error> {
        guard let url = Bundle.main.url(forResource: "test-history", withExtension: "json"),
              let jsonData = try? Data(contentsOf: url)
        else {
            Logger.persistence.debug("Failed to received valid response and/or data.")
            return Fail(error: AirAlertStateError.missingData)
                .eraseToAnyPublisher()
        }

        return Just(jsonData)
            .decode(type: [AirAlertStateProperties].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
