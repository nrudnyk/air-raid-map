//
//  air_raid_mapApp.swift
//  Shared
//
//  Created by Nazar Rudnyk on 20.04.2022.
//

import SwiftUI
#if os(iOS)
import WidgetKit
#endif

@main
struct AirRaidMapApp: App {
#if os(iOS)
    @Environment(\.scenePhase) private var scenePhase
#endif
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
#if os(iOS)
        .onChange(of: scenePhase) { phase in
            if phase == .background {
                print("went to background")
                WidgetCenter.shared.reloadTimelines(ofKind: WidgetCenter.Kind.mainMap)
            }
        }
#endif
    }
}
