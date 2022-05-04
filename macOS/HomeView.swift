//
//  MapView.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 20.04.2022.
//

import MapKit
import SwiftUI

struct HomeView: View {
    
    @StateObject private var viewModel = MapViewModel()
    
    var body: some View {
        NavigationView {
            regionListView
                .frame(minWidth: 275)
            mapView
                .navigationTitle("")
            
        }.toolbar { toolbar }
    }
}

private func toggleSidebar() {
    NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeView()
        }
    }
}

extension HomeView {
    @ToolbarContentBuilder
    fileprivate var toolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .navigation) {
            Button(action: toggleSidebar, label: {
                Image(systemName: "sidebar.leading")
            })
            regionListHeader
        }
        ToolbarItemGroup {
            Button(
                action: { viewModel.fitUkraineBounds() },
                label: { Image(systemName: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left") }
            )
            Button(
                action: { viewModel.reloadData() },
                label: { Image(systemName: "arrow.clockwise") }
            )
        }
    }
    
    fileprivate var mapView: some View {
        MapViewRepresentable(
            region: $viewModel.ukraineCoordinateRegion,
            overlays: viewModel.overlays
        )
    }
    
    fileprivate var regionListView: some View {
        VStack {
            regionListSectionHeader
            Divider()
            regionList
        }.padding([.horizontal])
    }
    
    fileprivate var regionListHeader: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Активні тривоги (\(viewModel.alarmedRegion.count))")
                    .font(.title3).bold()
                Text("станом на: \(DateFormatter.localizedString(from: viewModel.lastUpdate, dateStyle: .medium, timeStyle: .medium))")
                    .italic()
                    .font(.subheadline)
                    .frame(alignment: .trailing)
            }
            Spacer()
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
        ScrollView() {
            VStack {
                ForEach(viewModel.alarmedRegion) { regionState in
                    RegionStateListItemView(regionState: regionState)
                    Divider()
                }
                Spacer()
            }
        }
    }
}