//
//  MapViewInteractor.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 11.05.2022.
//

import Combine
import OSLog

class MapViewInteractor {
    @Published var regionsData: [RegionStateModel] = []
    
    private let airAlertsDataService: IAirAlertsDataService
    private var cancellables = Set<AnyCancellable>()

    private let regionsRepository = RegionsRepository()
    
    init(airAlertsDataService: IAirAlertsDataService = AirAlertsDataService()) {
        self.airAlertsDataService = airAlertsDataService
        
        reloadData()

        FetchedResultsPublisher(
            request: RegionStateDAO.getAllRegions(),
            context: AirAlertStatesProvider.shared.container.viewContext
        )
        .map { regions in
            return self.regionsRepository.regions.map { region in
                let alertState = regions.alertState(for: region.properties.NAME_1)
                return RegionStateModel(region: region, alertState: alertState)
            }
        }
        .replaceError(with: [])
        .assign(to: &$regionsData)
    }
    
    func reloadData() {
        airAlertsDataService.getData()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    Logger.persistence.debug("Successfully completed fetching alerts data.")
                case .failure(let error):
                    let err = AirAlertStateError.wrongDataFormat(error: error)
                    Logger.persistence.debug("Error while fetching latest alerts data: \(err.localizedDescription).")
                }
            }, receiveValue: { regions in
                Logger.persistence.debug("Received \(regions.count) records.")
                Logger.persistence.debug("Start inserting latest alerts data to the store...")
                Task {
                    await RegionStateDAO.insertLatestRegionaData(regions)
                }
                Logger.persistence.debug("Finished latest alert inserting data.")
            })
            .store(in: &cancellables)
    }
}
