//
//  AirAlertsDataService.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 27.04.2022.
//

import Foundation
import Combine

class AirAlertsDataService: IAirAlertsDataService {
    private let alertsApiEndpoint = "https://alerts.com.ua/api/states"
    private let apiKey = "X-API-Key"
    private let apiKeyValue = "df0ad7ea014f74e2bc741960c6d2f681c9cf34fd"

    private let regionsRepository = RegionsRepository()

    func getData() -> AnyPublisher<[RegionStateProperties], Error> {
        guard let url = URL(string: alertsApiEndpoint) else {
            return Fail(error: NSError(domain: "Missing Air-Raid Alarms URL", code: -10001, userInfo: nil))
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.setValue(apiKeyValue, forHTTPHeaderField: apiKey)
        request.httpMethod = "GET"
 
        return NetworkManager.download(request: request)
            .decode(type: RegionStatesDecodable.self, decoder: JSONDecoder())
            .map { regionsDecodable in
                print(regionsDecodable.lastUpdate)
                UserDefaults.standard.set(
                    DateFormatter.localizedString(from: regionsDecodable.lastUpdate, dateStyle: .medium, timeStyle: .medium),
                    forKey: UserDefaults.Keys.lastUpdate
                )
                return regionsDecodable.regionStates
            }
            .eraseToAnyPublisher()
    }
    
    func getHistoryData() -> AnyPublisher<[AirAlertStateProperties], Error> {
        fatalError()
    }
    
    func updateAlertsData(completion: @escaping ([RegionStateModel]) -> Void) {
        guard let url = URL(string: alertsApiEndpoint) else { return }
        
        var request = URLRequest(url: url)
        request.setValue(apiKeyValue, forHTTPHeaderField: apiKey)
        request.httpMethod = "GET"
 
        NetworkManager.download(request: request) { data in
            do {
                let regionsDecodable = try JSONDecoder().decode(RegionStatesDecodable.self, from: data)
                let regionStatesModel = self.regionsRepository.regions.map { region -> RegionStateModel in
                    let alertState = regionsDecodable.alertState(for: region.properties.NAME_1)
                    return RegionStateModel(region: region, alertState: alertState)
                }

                completion(regionStatesModel)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
