//
//  AirAlertStateModel.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 21.05.2022.
//

import Foundation

struct AirAlertStateModel: Identifiable, Decodable {
    private enum CodingKeys : String, CodingKey {
        case id = "id"
        case date = "date"
        case stateId = "state_id"
        case alertState = "alert"
    }

    let id: Int

//    let alertState: AlertState
    let date: String
    let stateId: Int
    let alertState: Bool


//    init(id: Int, date: Date, stateId: Int, alertState: Bool) {
//        self.id = id
//        self.stateId = stateId
//        self.alertState = AlertState(type: alertState ? .airAlarm : .allClear, changedAt: date)
//    }
}
