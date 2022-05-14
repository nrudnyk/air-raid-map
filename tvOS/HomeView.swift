//
//  MapView.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 20.04.2022.
//

import MapKit
import SwiftUI

struct HomeView: View {
    @State private var sidebarButtonId = 0
    @State private var isSidebarVisible = false
    
    @StateObject private var viewModel = MapViewModel()
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack {
                if (isSidebarVisible) {
                    regionListView
                        .frame(maxWidth: 750)
                        .focusSection()
                }

                ZStack(alignment: .topTrailing) {
                    MapViewRepresentable(
                        region: $viewModel.ukraineCoordinateRegion,
                        isZoomEnabled: false,
                        isScrollEnabled: false,
                        overlays: viewModel.overlays
                    )
                    .focusable(false)
                    .ignoresSafeArea()
                    
                    HStack(alignment: .top) {
                        if (!isSidebarVisible) {
                            sidebarButton
                        }
                        Spacer()
                        VStack() {
                            fitUkraineButton
                            refreshButton
                        }
                    }
                }.focusSection()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

extension HomeView {
    fileprivate var sidebarButton: some View {
        Button(
            action: { withAnimation { isSidebarVisible.toggle() }},
            label: { Image(systemName: "sidebar.leading") }
        ).id(sidebarButtonId)
    }
    
    fileprivate var refreshButton: some View {
        Button(
            action: { viewModel.reloadData() },
            label: { Image(systemName: "arrow.clockwise") }
        )
    }
    
    fileprivate var fitUkraineButton: some View {
        Button(
            action: { viewModel.fitUkraineBounds() },
            label: { Image(systemName: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left") }
        )
    }
    
    fileprivate var regionListHeader: some View {
        HStack {
            sidebarButton
            VStack(alignment: .leading) {
                Text("Активні тривоги (\(viewModel.alarmedRegions.count))")
                    .font(.title3).bold()
                Text("станом на: \(DateFormatter.localizedString(from: viewModel.lastUpdate, dateStyle: .medium, timeStyle: .medium))")
                    .italic()
                    .font(.subheadline)
                    .frame(alignment: .trailing)
            }
            Spacer()
        }
    }
    
    fileprivate var regionListView: some View {
        VStack {
            regionListHeader
            Divider()
            regionList
        }
    }
    
    fileprivate var regionListSectionHeader: some View {
        HStack {
            Text("Регіон")
            Spacer()
            Text("Оголошено в")
        }
        .font(.headline)
    }
    
    fileprivate var regionList: some View {
        List(viewModel.alarmedRegions) { regionState in
            RegionStateListItemView(regionState) {
                viewModel.focusOnRegion(regionState)
            }
        }
    }
}
