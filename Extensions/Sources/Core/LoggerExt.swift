//
//  LoggerExtensions.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 29.06.2022.
//

import OSLog

public extension Logger {
    static let persistence = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.nrudnyk", category: "persistence")
}
