//
//  RegionStateListItemView.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 23.04.2022.
//

import SwiftUI
import MapKit

struct RegionStateListItemView: View {
    let regionState: RegionStateModel
    let onItemSelected: () -> Void
    
    init(_ regionState: RegionStateModel, onItemSelected: @escaping () -> Void = {}) {
        self.regionState = regionState
        self.onItemSelected = onItemSelected
    }
    
    var body: some View {
#if os(macOS) || os(iOS)
        regionStateListItemContent
            .contentShape(Rectangle())
            .onTapGesture(perform: onItemSelected)
#elseif os(tvOS)
        Button(action: onItemSelected) {
            regionStateListItemContent
                .padding()
        }
#endif
    }
}

struct RegionStateListItemView_Previews: PreviewProvider {
    static var previews: some View {
        RegionStateListItemView(RegionStateModel(
            nameKey: "Kyiv",
            geometry: MKPolygon(),
            alertState: AlertState()
        ))
        .previewLayout(.sizeThatFits)
        .environment(\.locale, .init(identifier: "uk"))
    }
}

extension RegionStateListItemView {
    fileprivate var regionStateListItemContent: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text(LocalizedStringKey(regionState.nameKey))
                    .font(.headline)
                    .bold()
                Spacer()
            }
            
            HStack(spacing: 0) {
                Image(systemName: "clock.arrow.circlepath")
                Text(" ")
                switch regionState.alertState.type {
                case .airAlarm: Text("last").italic()
                case .allClear: Text("silence").italic()
                default: EmptyView()
                }
                Text(" ")
                Text(regionState.alertState.changedAt, style: .relative).italic()
            }
            .font(.footnote)
            .foregroundColor(regionState.alertState.type.color)
            
            if regionState.alertState.type == .airAlarm {
                HStack(spacing: 0) {
                    Image(systemName: "megaphone")
                    Text(" ")
                    Text("announced")
                    Text(" ")
                    Text(DateFormatter.timePreposition(for: regionState.alertState.changedAt))
                    Text(" ")
                    Text(regionState.alertState.changedAt, style: .time)
                }
                .font(.footnote)
                .foregroundColor(.orange)
            }
        }
    }
}
