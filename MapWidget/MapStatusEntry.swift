//
//  MapStatusEntry.swift
//  air-raid-map (iOS)
//
//  Created by Nazar Rudnyk on 01.05.2022.
//

import Foundation
import SwiftUI
import WidgetKit
import MapKit

struct MapStatusEntry: TimelineEntry {
    let date: Date
    let mapSnapshots: [ColorScheme: PlatformImage]
}
