//
//  WidgetExtensionApp.swift
//  air-raid-map (iOS-Widget)
//
//  Created by Nazar Rudnyk on 01.05.2022.
//

import WidgetKit
import SwiftUI

@main
struct air_raid_map_widget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: WidgetCenter.Kind.mainMap, provider: MapStatusTimelinePovider()) { entry in
            WidgetMapView(entry: entry)
        }
        .configurationDisplayName("Air-raid alerts in Ukraine")
        .configurationDisplayName("Карта повітряних тривог в Україні")
        .description("Shows a map with information about air-raid alerts in Ukraine")
        .description("Відображає карту з актуальною інформацією про повітряні тривоги в Україні")
    }
}
