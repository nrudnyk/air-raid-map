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
    
    private let regionsRepository = RegionsRepository()
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var ukraineCoordinateRegion = MapConstsants.boundsOfUkraine
    @Published var alarmedRegion: [RegionStateModel] = []
    @Published var overlays = [MKOverlay]()
    @Published var lastUpdate: Date = Date()
    
    init() {
        fitUkraineBounds()
        setUpTimer()
        updateRegionStates()
    }
    
    func fitUkraineBounds() {
        self.ukraineCoordinateRegion = MapConstsants.boundsOfUkraine
    }
    
    func updateRegionStates() {
        guard let url = URL(string: alertsApiEndpoint) else { return }
        
        var request = URLRequest(url: url)
        request.setValue(apiKeyValue, forHTTPHeaderField: apiKey)
        request.httpMethod = "GET"
        
        NetworkManager.download(request: request)
            .decode(type: RegionStatesDecodable.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .map { [weak self] regionStatesDecodable in
                guard let self = self else { return [] }
                
                self.lastUpdate = regionStatesDecodable.lastUpdate
                
                return self.regionsRepository.regions.map { region in
                    RegionStateModel(
                        id: region.properties.ID_0,
                        name: region.properties.NAME_1,
                        geometry: region.geometry.first!,
                        alertState: regionStatesDecodable.alertState(for: region)
                    )
                }
            }
            .passthrough { [weak self] resionStateModels in self?.alarmedRegion = resionStateModels.filter { $0.alertState.type == .airAlarm } }
            .map(updateOverlays(regionStateModels:))
            .replaceError(with: [])
            .assign(to: &$overlays)
    }
    
    private func setUpTimer() {
        Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .subscribe(on: DispatchQueue.global(qos: .background))
            .sink { [weak self] _ in self?.updateRegionStates() }
            .store(in: &cancellables)
    }
    
    private func updateOverlays(regionStateModels: [RegionStateModel]) -> [RegionOverlay] {
        return regionStateModels.map { model in
            RegionOverlay(
                shape: model.geometry,
                color: model.alertState.type.color
            )
        }
    }
}
