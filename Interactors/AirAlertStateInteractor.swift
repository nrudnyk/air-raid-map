//
//  AirAlertStateInteractor.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 27.06.2022.
//

import Foundation
import Combine
import OSLog

class AirAlertStateInteractor {
    private let airAlertsDataService: IAirAlertsDataService
    private var cancellables = Set<AnyCancellable>()

    init(airAlertsDataService: IAirAlertsDataService = StubAirAlertsDataService()) {
        self.airAlertsDataService = airAlertsDataService
    }

    func tryGetLatestHistory() {
        airAlertsDataService.getHistoryData()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    Logger.persistence.debug("Successfully completed fetching history data.")
                case .failure(let error):
                    let err = AirAlertStateError.wrongDataFormat(error: error)
                    Logger.persistence.debug("Error while fetching history data: \(err.localizedDescription).")
                }
            }, receiveValue: { values in
                Logger.persistence.debug("Received \(values.count) records.")
                Logger.persistence.debug("Start importing data to the store...")
                Task {
                    try await AirAlertStateDAO.importAirAlertStates(from: values)
                }
                Logger.persistence.debug("Finished importing data.")

            })
            .store(in: &cancellables)
    }
}
