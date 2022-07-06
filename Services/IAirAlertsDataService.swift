//
//  IAirAlertsDataService.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 11.05.2022.
//

import Foundation
import Combine

protocol IAirAlertsDataService {
    func getData() -> AnyPublisher<[RegionStateProperties], Error>
    
    func getHistoryData() -> AnyPublisher<[AirAlertStateProperties], Error>
}
