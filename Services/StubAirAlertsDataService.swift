//
//  StubAirAlertsDataService.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 11.05.2022.
//

import Foundation
import Combine

class StubAirAlertsDataService: IAirAlertsDataService {
    
    @Published var lastUpdate: Date = Date()
    
    private let regionsRepository = RegionsRepository()
    
    func getLastUpdate() -> AnyPublisher<Date, Never> {
        return $lastUpdate.eraseToAnyPublisher()
    }
    
    func getData() -> AnyPublisher<[RegionStateModel], Error> {
        guard let url = Bundle.main.url(forResource: "test-sirens", withExtension: "json"),
              let jsonData = try? Data(contentsOf: url)
        else {
            return Fail(error: GeoJSONError.invalidType)
                .eraseToAnyPublisher()
        }
        
        return Just(jsonData)
            .decode(type: RegionStatesDecodable.self, decoder: JSONDecoder())
            .map { [weak self] regionsDecodable in
                guard let self = self else { return [] }
    
                self.lastUpdate = regionsDecodable.lastUpdate
                
                return self.regionsRepository.regions.map { region in
                    let alertState = regionsDecodable.alertState(for: region.properties.NAME_1)
                    return RegionStateModel(region: region, alertState: alertState)
                }
            }
            .eraseToAnyPublisher()
    }
}

