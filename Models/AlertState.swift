//
//  AlertState.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 27.04.2022.
//

import Foundation
import CoreGraphics
import SwiftUI

public enum AlertType: String, CaseIterable {
    case airAlarm = "Air-Alarm"
    case allClear = "All-Clear"
    case noInfo = "No-Info"

    var systemImage: String {
        switch self {
        case .airAlarm: return "bell"
        case .allClear: return "bell.slash"
        case .noInfo: return "line.3.horizontal"
        }
    }

    var color: Color {
        switch self {
        case .airAlarm: return .red
        case .allClear: return Color(.systemGreen)// Color(cgColor: UIColor.systemGreen.cgColor)
        case .noInfo: return .gray
        }
    }
}

public struct AlertState {
    let type: AlertType
    let changedAt: Date
    
    init(type: AlertType = .noInfo, changedAt: Date = Date()) {
        self.type = type
        self.changedAt = changedAt
//        let date = Calendar.current.date(byAdding: .hour, value: (28*24+23), to: changedAt)!
//        self.changedAt = Calendar.current.date(byAdding: .minute, value: 24, to: date)!
    }
    
    var color: PlatformColor {
        switch type {
        case .airAlarm:
            return ColorIntencity(timeInterval: Date().timeIntervalSince1970 - changedAt.timeIntervalSince1970).color
        case .allClear:
            return PlatformColor(red: 50/255, green: 200/255, blue: 210/255, alpha: 0.5)
        case .noInfo:
            return PlatformColor(red: 201/255, green: 199/255, blue: 195/255, alpha: 0.65)
        }
    }
}

fileprivate enum ColorIntencity {
    case xLight     // < 5min
    case light      // < 1h
    case medium     // < 2h
    case saturated  // < 6h
    case xSaturated // > 6h
    
    init(timeInterval: TimeInterval) {
        let duration = timeInterval / 60
        
        if duration < 5 { self = .xLight }
        else if duration < 60 { self = .light }
        else if duration < 60 * 2 { self = .medium }
        else if duration < 60 * 6 { self = .saturated }
        else { self = .xSaturated }
    }
    
    var color: PlatformColor {
        switch self {
        case .xLight: return PlatformColor(red: 179/255, green: 46/255, blue: 28/255, alpha: self.opacity)
        case .light: return PlatformColor(red: 160/255, green: 41/255, blue: 26/255, alpha: self.opacity)
        case .medium: return PlatformColor(red: 143/255, green: 35/255, blue: 23/255, alpha: self.opacity)
        case .saturated: return PlatformColor(red: 124/255, green: 31/255, blue: 18/255, alpha: self.opacity)
        case .xSaturated: return PlatformColor(red: 107/255, green: 25/255, blue: 15/255, alpha: self.opacity)
        }
    }
    
    fileprivate var opacity: CGFloat {
        switch self {
        case .xLight: return 0.7
        case .light: return 0.7
        case .medium: return 0.7
        case .saturated: return 0.8
        case .xSaturated: return 0.9
        }
    }
}
