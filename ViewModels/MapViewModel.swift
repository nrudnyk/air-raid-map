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
    @Published var selectedAlertType: AlertType = .airAlarm
    @Published var regions: [RegionStateModel] = []
    @Published var selectedRegion: RegionStateModel? = nil
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
            .map { $0.sorted(by: { $0.alertState.changedAt > $1.alertState.changedAt} ) }
            .receive(on: DispatchQueue.main)
            .assign(to: &$regions)

        self.mapViewInteractor.$regionsData
            .combineLatest($selectedRegion)
            .map { regions, selectedRegion in
                if let region = selectedRegion {
                    return [RegionOverlay(regionStateModel: region)]
                } else {
                    return regions.map(RegionOverlay.init)
                }
            }
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

extension Array where Element == RegionStateModel {
    func filtered(by alertType: AlertType) -> [RegionStateModel] {
        self.filter {
            switch alertType {
            case .airAlarm: return $0.alertState.type == .airAlarm
            case .allClear: return $0.alertState.type == .allClear
            case .noInfo: return $0.alertState.type != .noInfo
            }
        }
    }
}
