//
//  AirAlertsDataService.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 27.04.2022.
//

import Foundation
import Combine

class AirAlertsDataService {
    private let alertsApiEndpoint = "https://alerts.com.ua/api/states"
    private let apiKey = "X-API-Key"
    private let apiKeyValue = "df0ad7ea014f74e2bc741960c6d2f681c9cf34fd"

    @Published var lastUpdate: Date = Date()
    @Published var regionsData: [RegionStateModel] = []

    private let regionsRepository = RegionsRepository()
    
    init() {
        updateAlertsData()
    }
    
    func updateAlertsData() {
        guard let url = URL(string: alertsApiEndpoint) else { return }
        
        var request = URLRequest(url: url)
        request.setValue(apiKeyValue, forHTTPHeaderField: apiKey)
        request.httpMethod = "GET"
 
        NetworkManager.download(request: request)
            .decode(type: RegionStatesDecodable.self, decoder: JSONDecoder())
            .map { [weak self] regionStatesDecodable in
                guard let self = self else { return [] }
                
                self.lastUpdate = regionStatesDecodable.lastUpdate
                
                return self.regionsRepository.regions.map { region in
                    return self.makeRegionStateModel(region, alertState: regionStatesDecodable.alertState(for: region))
                }
            }
            .replaceError(with: [])
            .assign(to: &$regionsData)
    }
    
    func updateAlertsData(completion: @escaping ([RegionStateModel]) -> Void) {
        guard let url = URL(string: alertsApiEndpoint) else { return }
        
        var request = URLRequest(url: url)
        request.setValue(apiKeyValue, forHTTPHeaderField: apiKey)
        request.httpMethod = "GET"
 
        NetworkManager.download(request: request) { data in
            do {
                let regionsDecodable = try JSONDecoder().decode(RegionStatesDecodable.self, from: data)
                let regionStatesModel = self.regionsRepository.regions.map { region in
                    return self.makeRegionStateModel(region, alertState: regionsDecodable.alertState(for: region))
                }

                completion(regionStatesModel)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func makeRegionStateModel(_ region: Region, alertState: AlertState) -> RegionStateModel {
        return  RegionStateModel(
            id_0: region.properties.ID_0,
            name: region.properties.NAME_1,
            geometry: region.geometry.first!,
            alertState: alertState
        )
    }
}
