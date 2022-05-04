//
//  MapStatusProvider.swift
//  air-raid-map (iOS)
//
//  Created by Nazar Rudnyk on 01.05.2022.
//

import Foundation
import WidgetKit
import Combine
import SwiftUI
import MapKit

class MapStatusTimelinePovider: TimelineProvider {
    private let regionRepository = RegionsRepository()
    private let previewRegions: [RegionStateModel]
    private let airAlertsDataService = AirAlertsDataService()

    init() {
        previewRegions = regionRepository.regions.map { region in
            RegionStateModel(
                id_0: region.properties.ID_0,
                name: region.properties.NAME_1,
                geometry: region.geometry.first!,
                alertState: AlertState(type: .allClear, changedAt: Date())
            )
        }
    }
    
    func placeholder(in context: Context) -> MapStatusEntry {
        return MapStatusEntry(
            date: Date(),
            mapSnapshots: [:]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (MapStatusEntry) -> ()) {
        let date = Date()
        
        if context.isPreview {
            let overlays = getOverlays(previewRegions)

            MapWidgetSnapshotter.makeMapSnapshots(for: overlays, size: context.displaySize) { snapshots in
                completion(MapStatusEntry(date: date, mapSnapshots: snapshots))
            }
        } else {
            airAlertsDataService.updateAlertsData { regions in
                let overlays = self.getOverlays(regions)
                MapWidgetSnapshotter.makeMapSnapshots(for: overlays, size: context.displaySize) { snapshots in
                    completion(MapStatusEntry(date: date, mapSnapshots: snapshots))
                }
            }
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MapStatusEntry>) -> ()) {
        let date = Date()
        
        airAlertsDataService.updateAlertsData { regions in
            let overlays = self.getOverlays(regions)
            MapWidgetSnapshotter.makeMapSnapshots(for: overlays, size: context.displaySize) { snapshots in
                completion(Timeline(
                    entries: [MapStatusEntry(date: date, mapSnapshots: snapshots)],
                    policy: .after(Calendar.current.date(byAdding: .minute, value: 5, to: date)!)
                ))
            }
        }
    }
    
    private func getOverlays(_ regions: [RegionStateModel]) -> [RegionOverlay] {
        return regions.map { model in
            return RegionOverlay(shape: model.geometry, color: model.alertState.type.color)
        }
    }
}
