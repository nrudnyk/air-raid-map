//
//  AlertState.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 27.04.2022.
//

import Foundation

public enum AlertType {
    case airAlarm
    case allClear
    case noInfo
    
    var color: PlatformColor {
        switch self {
        case .airAlarm:
            return PlatformColor(red: 194/255, green: 59/255, blue: 34/255, alpha: 0.5)
        case .allClear:
            return PlatformColor(red: 50/255, green: 200/255, blue: 210/255, alpha: 0.5)
        case .noInfo:
            return PlatformColor(red: 201/255, green: 199/255, blue: 195/255, alpha: 0.65)
        }
    }
}

public struct AlertState {
    let type: AlertType
    let changedAt: Date
    
    init(type: AlertType = .noInfo, changedAt: Date = Date()) {
        self.type = type
        self.changedAt = changedAt
    }
}
