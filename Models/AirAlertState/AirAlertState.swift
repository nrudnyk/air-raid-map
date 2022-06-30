//
//  AirAlertState.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 28.06.2022.
//

import CoreData
import SwiftUI
import OSLog

// MARK: - Core Data

/// Managed object subclass for the AirAlertState entity.
class AirAlertState: NSManagedObject {

    // A unique identifier used to avoid duplicates in the persistent store.
    // Constrain the Quake entity on this attribute in the data model editor.
    @NSManaged var id: Int

    // The characteristics of a AirAlert State.
    @NSManaged var date: Date
    @NSManaged var region_id: Int16
    @NSManaged var state: Bool

    func update(from alertStateProperties: AirAlertStateProperties) throws {
        id = alertStateProperties.id
        date = alertStateProperties.date
        region_id = alertStateProperties.regionId
        state = alertStateProperties.state
    }
}

// MARK: - SwiftUI

extension AirAlertState {

    static var preview = AirAlertState.makePreviews(count: 1)[0]

    @discardableResult
    static func makePreviews(count: Int) -> [AirAlertState] {
        var alerts = [AirAlertState]()
        let viewContext = AirAlertStatesProvider.preview.container.viewContext
        for i in 0..<count {
            let alert = AirAlertState(context: viewContext)
            alert.id = i
            alert.date = Date().addingTimeInterval(Double(i) * -300)
            alert.region_id = .random(in: 0...25)
            alert.state = i / 2 == 0

            alerts.append(alert)
        }
        return alerts
    }
}

/// A struct encapsulating the properties of a AirAlertState.
struct AirAlertStateProperties: Decodable {

    // MARK: Codable
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case date = "date"
        case regionId = "state_id"
        case state = "alert"
    }

    let id: Int         // "id": 46,
    let date: Date      // "date": "2022-03-16T02:55:03+02:00",
    let regionId: Int16 // "state_id": 14,
    let state: Bool     // "alert": true

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let rawId = try? values.decode(Int.self, forKey: .id)
        let rawDate = try? values.decode(String.self, forKey: .date)
        let rawStateId = try? values.decode(Int16.self, forKey: .regionId)
        let rawState = try? values.decode(Bool.self, forKey: .state)

        // Ignore air alert state with missing data.
        guard let id = rawId,
              let dateStr = rawDate,
              let stateId = rawStateId,
              let state = rawState
        else { throw AirAlertStateError.missingData }

        guard let date = DateFormatter.iso8601Full.date(from: dateStr)
        else { throw AirAlertStateError.missingData }

        self.id = id
        self.date = date
        self.regionId = stateId
        self.state = state
    }

    // The keys must have the same name as the attributes of the AirAlertState entity.
    var dictionaryValue: [String: Any] {
        [
            "id": id,
            "date": date,
            "region_id": regionId,
            "state": state
        ]
    }
}
