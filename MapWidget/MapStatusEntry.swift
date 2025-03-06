//
//  MapStatusEntry.swift
//  air-raid-map (iOS)
//
//  Created by Nazar Rudnyk on 01.05.2022.
//

import Extensions
import SwiftUI
import WidgetKit
import MapKit
import Extensions

struct MapStatusEntry: TimelineEntry {
    let date: Date
    let mapSnapshots: [ColorScheme: PlatformImage]
}
