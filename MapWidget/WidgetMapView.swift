//
//  WidgetMapView.swift
//  air-raid-map (iOS-Widget)
//
//  Created by Nazar Rudnyk on 01.05.2022.
//

import SwiftUI
import WidgetKit

struct WidgetMapView: View {
    @Environment(\.colorScheme) var colorScheme
    var entry: MapStatusEntry

    var body: some View {
        ZStack(alignment: .bottom) {
#if os(iOS)
            if let mapSnapshot = entry.mapSnapshots[colorScheme] {
                Image(uiImage: mapSnapshot)
            } else {
                Color(UIColor.secondarySystemBackground)
            }
#elseif os(macOS)
            if let mapSnapshot = entry.mapSnapshots[colorScheme] {
                Image(nsImage: mapSnapshot)
            } else {
                Color(.controlBackgroundColor)
            }
#endif
            
            Text(DateFormatter.localizedString(from: entry.date, dateStyle: .none, timeStyle: .short))
                .bold()
                .foregroundColor(.secondary)
                .font(.footnote)
        }
    }
}
