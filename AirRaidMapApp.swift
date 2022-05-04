//
//  air_raid_mapApp.swift
//  Shared
//
//  Created by Nazar Rudnyk on 20.04.2022.
//

import SwiftUI
import WidgetKit

@main
struct AirRaidMapApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { phase in
            if phase == .background {
                print("went to background")
                WidgetCenter.shared.reloadTimelines(ofKind: WidgetCenter.Kind.mainMap)
            }
        }
    }
}
