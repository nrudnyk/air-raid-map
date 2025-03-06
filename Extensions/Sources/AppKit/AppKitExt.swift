//
//  AppKitExtensions.swift
//  air-raid-map (macOS)
//
//  Created by Nazar Rudnyk on 14.05.2022.
//

#if os(macOS)

import AppKit

public extension NSEdgeInsets {
    static let zero = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
}

public extension NSSharingService {
    static let items = NSSharingService.sharingServices(forItems: [""])
}

#endif
