//
//  MapViewModel.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 20.04.2022.
//

import MapKit
import SwiftUI

class MapViewModel: ObservableObject {
    private let regionsRepository = RegionsRepository()
    
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D.centerOfUkraine,
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    @Published var overlays = [MKOverlay]()
    
    init() {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = "UA"
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown error").")
                return
            }
            
            let bounds = response.boundingRegion
            self.region = bounds
        }
        
        updateOverlays()
    }
    
    private func updateOverlays() {
        guard let alertStates = MapViewModel.getAlertStates(from: "test-sirens") else { return }
        
        self.overlays = alertStates.states
            .compactMap {
                guard let region = regionsRepository.regions[$0.id],
                      let geometry = region.geometry.first
                else { return nil }
                
                let color = $0.alert
                    ? PlatformColor(red: 194/255, green: 59/255, blue: 34/255, alpha: 1)
                    : PlatformColor(red: 50/255, green: 200/255, blue: 210/255, alpha: 1)
                return RegionOverlay(shape: geometry, color: color)
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
