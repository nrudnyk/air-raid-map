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
        
        var overlays = [MKOverlay]()
        let filteredStated: [RegionStateModel] = alertStates.states
            .filter { $0.alert }
        
        for state in filteredStated {
            guard let region = regionsRepository.regions[state.id],
                  let geometry = region.geometry.first
            else { continue }
            
            let shape: MKShape = geometry
            
            overlays.append(shape as! MKOverlay)
        }
        
        self.overlays = overlays
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
