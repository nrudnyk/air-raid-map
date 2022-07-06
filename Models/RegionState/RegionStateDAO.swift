//
//  RegionStateDAO.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 05.07.2022.
//

import Foundation
import CoreData
import OSLog

class RegionStateDAO {
    private static let alertsProvider: AirAlertStatesProvider = .shared

    static func getAllRegions() -> NSFetchRequest<RegionState> {
        let sortDescriptor = NSSortDescriptor(keyPath: \RegionState.id, ascending: true)

        let fetchRequest = NSFetchRequest<RegionState>(entityName: String(describing: RegionState.self))
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        return fetchRequest
    }

    static func insertLatestRegionaData(_ regions: [RegionStateProperties]) async {
        let context = alertsProvider.container.viewContext
        await context.perform {
            for regionProperties in regions {
                let newRegion = RegionState(context: context)
                newRegion.update(from: regionProperties)
            }

            alertsProvider.save()
        }
    }
}
