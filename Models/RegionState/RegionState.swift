//
//  RegionState.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 05.07.2022.
//

import CoreData

class RegionState: NSManagedObject {
    // A unique identifier used to avoid duplicates in the persistent store.
    @NSManaged var id: Int16
    // The characteristics of a Region State.
    @NSManaged var name: String
    @NSManaged var name_en: String
    @NSManaged var alert: Bool
    @NSManaged var changed: Date

    func update(from regionStateProperties: RegionStateProperties) {
        id = regionStateProperties.id
        name = regionStateProperties.name
        name_en = regionStateProperties.name_en
        alert = regionStateProperties.alert
        changed = regionStateProperties.changed
    }
}

struct RegionStateProperties: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case name_en = "name_en"
        case alert = "alert"
        case changed = "changed"
    }

    let id: Int16
    let name: String
    let name_en: String
    let alert: Bool
    let changed: Date

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let rawId = try? values.decode(Int16.self, forKey: .id)
        let rawName = try? values.decode(String.self, forKey: .name)
        let rawNameEn = try? values.decode(String.self, forKey: .name_en)
        let rawAlert = try? values.decode(Bool.self, forKey: .alert)
        let rawChangedAt = try? values.decode(String.self, forKey: .changed)

        // Ignore region state with missing data.
        guard let id = rawId,
              let name = rawName,
              let nameEn = rawNameEn,
              let alert = rawAlert,
              let dateStr = rawChangedAt
        else { throw AirAlertStateError.missingData }

        guard let changedDate = DateFormatter.iso8601Full.date(from: dateStr)
        else { throw AirAlertStateError.missingData }

        self.id = id
        self.name = name
        self.name_en = nameEn
        self.alert = alert
        self.changed = changedDate
    }
}
