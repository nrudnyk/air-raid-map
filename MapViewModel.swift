//
//  MapViewModel.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 20.04.2022.
//

import MapKit
import SwiftUI
import Combine

class MapViewModel: ObservableObject {
    private let alertsApiEndpoint = "https://alerts.com.ua/api/states"
    private let apiKey = "X-API-Key"
    private let apiKeyValue = "df0ad7ea014f74e2bc741960c6d2f681c9cf34fd"
    
    private lazy var jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.iso8601Full)
        
        return decoder
    }()
    
    private let regionsRepository = RegionsRepository()
    
    private var cancellables = Set<AnyCancellable>()
    private var alertStatesSubscription: AnyCancellable?
    
    @Published var region = MapConstsants.boundsOfUkraine
    @Published var regionStates: [RegionStateModel] = []
    @Published var overlays = [MKOverlay]()
    @Published var lastUpdate: Date = Date()
    
    init() {
        fitUkraineBounds()
        setUpTimer()
        updateRegionStates()
    }
    
    func fitUkraineBounds() {
        self.region = MapConstsants.boundsOfUkraine
    }
    
    func updateRegionStates() {
        guard let url = URL(string: alertsApiEndpoint) else { return }
        
        var request = URLRequest(url: url)
        request.setValue(apiKeyValue, forHTTPHeaderField: apiKey)
        request.httpMethod = "GET"
        
        alertStatesSubscription = NetworkManager.download(request: request)
            .decode(type: AlertStateModel.self, decoder: jsonDecoder)
            .receive(on: DispatchQueue.main)
            .passthrough { [weak self] alertStateModel in
                guard let self = self else { return }
                
                self.lastUpdate = DateFormatter.iso8601UTC.date(from: alertStateModel.last_update) ?? Date()
                self.regionStates = alertStateModel.states.filter(\.alert)
            }
            .map(\.states)
            .map(updateOverlays(states:))
            .sink(receiveCompletion: NetworkManager.handleCompletion, receiveValue: { [weak self] overlays in
                guard let self = self else { return }
                
                self.overlays = overlays
                self.alertStatesSubscription?.cancel()
            })
    }
    
    private func setUpTimer() {
        Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .subscribe(on: DispatchQueue.global(qos: .background))
            .sink { [weak self] _ in self?.updateRegionStates() }
            .store(in: &cancellables)
    }
    
    private func updateOverlays(states: [RegionStateModel]) -> [RegionOverlay] {
        return states.compactMap {
            guard let region = regionsRepository.regions[$0.id],
                  let geometry = region.geometry.first
            else { return nil }
            
            let color = $0.alert
                ? PlatformColor(red: 194/255, green: 59/255, blue: 34/255, alpha: 1)
                : PlatformColor(red: 50/255, green: 200/255, blue: 210/255, alpha: 1)
            
            return RegionOverlay(shape: geometry, color: color.withAlphaComponent(0.5))
        }
    }
    
    private static func getAlertStates(from json: String) -> AlertStateModel? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.iso8601Full)
        
        guard let url = Bundle.main.url(forResource: json, withExtension: "json"),
              let jsonData = try? Data(contentsOf: url),
              let alertStates = try? decoder.decode(AlertStateModel.self, from: jsonData)
        else {
            return nil
        }

        return alertStates
    }
}
