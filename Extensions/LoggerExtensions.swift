//
//  LoggerExtensions.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 29.06.2022.
//

import OSLog

extension Logger {
    static let persistence = Logger(subsystem: "com.nrudnyk.air-raid-alerts", category: "persistence")
}
