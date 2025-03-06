//
//  AppKitExtensions.swift
//  air-raid-map (macOS)
//
//  Created by Nazar Rudnyk on 14.05.2022.
//

#if os(macOS)

import AppKit

extension NSEdgeInsets {
    public static let zero = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
}

extension NSSharingService {
    static let items = NSSharingService.sharingServices(forItems: [""])
}

#endif
