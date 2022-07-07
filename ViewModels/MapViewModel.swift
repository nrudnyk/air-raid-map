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
    
    @Published var activeAlarmsTitle: String = "active_sirens".localized
    @Published var activeAlarmsSubtitle: String = ""

    @Published var selectedAlertType: AlertType = .airAlarm
    @Published var regions: [RegionStateModel] = []
    @Published var overlays = [RegionOverlay]()
    @Published var isNetworkReachable: Bool = true
    
    private let mapViewInteractor: MapViewInteractor
    private let airAlertStateInteractor: AirAlertStateInteractor
    private var cancellables = Set<AnyCancellable>()

    init(
        mapViewInteractor: MapViewInteractor = MapViewInteractor(),
        airAlertStateInteractor: AirAlertStateInteractor = AirAlertStateInteractor()
    ) {
        self.mapViewInteractor = mapViewInteractor
        self.airAlertStateInteractor = airAlertStateInteractor
        
        setUpTimer()

        self.mapViewInteractor.$regionsData
            .combineLatest($selectedAlertType)
            .map { regionsData, selectedType in
                regionsData.filter { region in
                    switch selectedType {
                    case .airAlarm: return region.alertState.type == .airAlarm
                    case .allClear: return region.alertState.type == .allClear
                    case .noInfo: return region.alertState.type != .noInfo
                    }
                }
                .sorted(by: { $0.alertState.changedAt > $1.alertState.changedAt} )
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$regions)
        
        self.mapViewInteractor.$regionsData
            .map { $0.map(RegionOverlay.init) }
            .receive(on: DispatchQueue.main)
            .assign(to: &$overlays)

        NetworkManager.getNetworkState()
            .receive(on: DispatchQueue.main)
            .assign(to: &$isNetworkReachable)
    }
    
    func reloadData() {
        mapViewInteractor.reloadData()
    }
    
    private func setUpTimer() {
        Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .subscribe(on: DispatchQueue.global(qos: .background))
            .sink { [weak self] _ in self?.mapViewInteractor.reloadData() }
            .store(in: &cancellables)
    }
}
