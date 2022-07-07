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
        RegionStateListItemViewContent(name: regionState.nameKey, state: regionState.alertState)
            .contentShape(Rectangle())
            .onTapGesture(perform: onItemSelected)
#elseif os(tvOS)
        Button(action: onItemSelected) {
            RegionStateListItemViewContent(name: regionState.nameKey, state: regionState.alertState)
                .padding()
        }
#endif
    }
}
