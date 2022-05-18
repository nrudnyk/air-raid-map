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
    
    @Published var activeAlarmsTitle: String = ""
    @Published var activeAlarmsSubtitle: String = ""
    
    @Published var ukraineCoordinateRegion = MapConstsants.boundsOfUkraine
    @Published var alarmedRegions: [RegionStateModel] = []
    @Published var focusedRegion: RegionStateModel? = nil
    @Published var overlays = [MKOverlay]()
    @Published var lastUpdate: Date = Date()
    
    private let mapViewInteractor: MapViewInteractor
    private var cancellables = Set<AnyCancellable>()

    init(mapViewInteractor: MapViewInteractor = MapViewInteractor()) {
        self.mapViewInteractor = mapViewInteractor
        
        fitUkraineBounds()
        setUpTimer()

        self.mapViewInteractor.$regionsData
            .map { regions in regions.filter { $0.alertState.type == .airAlarm }}
            .map { regions in regions.sorted(by: { $0.alertState.changedAt > $1.alertState.changedAt} )}
            .receive(on: DispatchQueue.main)
            .assign(to: &$alarmedRegions)
        
        self.mapViewInteractor.$regionsData
            .map { $0.map(RegionOverlay.init) }
            .receive(on: DispatchQueue.main)
            .assign(to: &$overlays)

        self.mapViewInteractor.$lastUpdate
            .receive(on: DispatchQueue.main)
            .assign(to: &$lastUpdate)
        
        $alarmedRegions
            .map { "\("active_sirens".localized) - \($0.count)" }
            .assign(to: &$activeAlarmsTitle)
        
        $lastUpdate
            .map { "\("as_of".localized) \(DateFormatter.localizedString(from: $0, dateStyle: .medium, timeStyle: .medium))" }
            .assign(to: &$activeAlarmsSubtitle)
    }
    
    func focusOnRegion(_ region: RegionStateModel) {
        ukraineCoordinateRegion = MKCoordinateRegion(region.boudingRegion)
        focusedRegion = region
    }
    
    func fitUkraineBounds() {
        DispatchQueue.main.async {
            self.ukraineCoordinateRegion = MapConstsants.boundsOfUkraine
        }
        focusedRegion = nil
    }
    
    func reloadData() {
        mapViewInteractor.reloadData()
    }
    
    func shareMapSnapshot() {
#if os(iOS)
        let overlays = mapViewInteractor.regionsData.map(RegionOverlay.init)
        MapWidgetSnapshotter.makeMapSnapshot(for: overlays, size: CGSize(width: 800, height: 600)) { [weak self] snapshot in
            guard let self = self else { return }
            
            let imageActivityItemSource = ImageActivityItemSource(
                title: self.activeAlarmsTitle,
                text: self.activeAlarmsSubtitle,
                image: snapshot
            )
            
            let activityController = UIActivityViewController(activityItems: [imageActivityItemSource], applicationActivities: nil)
            UIApplication.shared.windows.first?.rootViewController!.present(activityController, animated: true, completion: {
                let hapticFeedbacGenerator = UINotificationFeedbackGenerator()
                hapticFeedbacGenerator.notificationOccurred(.success)
            })
        }
#endif
    }
    
    private func setUpTimer() {
        Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .subscribe(on: DispatchQueue.global(qos: .background))
            .sink { [weak self] _ in self?.mapViewInteractor.reloadData() }
            .store(in: &cancellables)
    }
}
