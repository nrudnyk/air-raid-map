//
//  AirAlertStateDAOswift.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 26.06.2022.
//

import Foundation
import CoreData
import OSLog

class AirAlertStateDAO {
    private static let alertsProvider: AirAlertStatesProvider = .shared

    static func getAllAlerts() -> NSFetchRequest<AirAlertState> {
        let fetchRequest = NSFetchRequest<AirAlertState>(entityName: String(describing: AirAlertState.self))
        return fetchRequest
    }

    static func getAlertsGroupedBy(_ groupBy: String) -> NSFetchRequest<AirAlertState> {
        let sortDescriptor = NSSortDescriptor(keyPath: \AirAlertState.date, ascending: true)

        let fetchRequest = Self.getAllAlerts()
        fetchRequest.propertiesToGroupBy = [\AirAlertState.id]
        fetchRequest.sortDescriptors = [sortDescriptor]


        return fetchRequest
    }

    static func getAllAirAlertsSorted(by sortDescriptorKey: String = "date") -> NSFetchRequest<AirAlertState> {
        let request = Self.getAllAlerts()
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)

        request.sortDescriptors = [sortDescriptor]

        return request
    }

    static func importAirAlertStates(from propertiesList: [AirAlertStateProperties]) async throws {
        guard !propertiesList.isEmpty else { return }

        let taskContext = alertsProvider.newBackgroundTaskContext()
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importAlerts"

        try await taskContext.performBlock {
            let batchInsertRequest = self.newBatchInsertRequest(with: propertiesList)
            if let fetchResult = try? taskContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult,
               let success = batchInsertResult.result as? Bool, success {
                return
            }

            Logger.persistence.debug("Failed to execute batch insert request.")
            throw AirAlertStateError.batchInsertError
        }
        Logger.persistence.debug("Successfully inserted data.")
    }

    private static func newBatchInsertRequest(with propertyList: [AirAlertStateProperties]) -> NSBatchInsertRequest {
        var index = 0
        let total = propertyList.count

        // Provide one dictionary at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(entity: AirAlertState.entity(), dictionaryHandler: { dictionary in
            guard index < total else { return true }
            dictionary.addEntries(from: propertyList[index].dictionaryValue)
            index += 1
            return false
        })

        return batchInsertRequest
    }
}
