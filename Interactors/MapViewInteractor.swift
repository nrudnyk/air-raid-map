//
//  MapViewInteractor.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 11.05.2022.
//

import Foundation

class MapViewInteractor {
    @Published var lastUpdate: Date = Date()
    @Published var regionsData: [RegionStateModel] = []
    
    private let airAlertsDataService: IAirAlertsDataService
    
    init(airAlertsDataService: IAirAlertsDataService = AirAlertsDataService()) {
        self.airAlertsDataService = airAlertsDataService
        
        reloadData()
    }
    
    func reloadData() {
        airAlertsDataService.getData()
            .replaceError(with: [])
            .assign(to: &$regionsData)
        
        airAlertsDataService.getLastUpdate()
            .assign(to: &$lastUpdate)
    }
}
