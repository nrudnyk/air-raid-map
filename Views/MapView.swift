//
//  MapView.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 20.04.2022.
//

import MapKit
import SwiftUI
#if os(iOS)
import BottomSheet
#endif

struct MapView: View {
#if os(iOS)
    @LandscapeOrientation var isLandscape
    @State var bottomSheetPosition: BottomSheetPosition = .bottom
#endif
    
    @StateObject private var viewModel = MapViewModel()
    
    var body: some View {
        ZStack {
            MapViewRepresentable(
                region: $viewModel.ukraineCoordinateRegion,
                overlays: viewModel.overlays
            ).ignoresSafeArea()
#if os(iOS)
            GeometryReader { gReader in
                Color.clear
                    .bottomSheet(
                        bottomSheetPosition: $bottomSheetPosition,
                        headerContent: { regionListHeader },
                        mainContent: { regionListView }
                    )
                    .padding(.trailing, isLandscape ? gReader.size.width / 7 * 4 : 0)
                    .offset(x: -gReader.safeAreaInsets.leading / 2, y: 0)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
#endif
        }
    }
}

#if os(iOS)
struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15.0, *) {
            MapView(bottomSheetPosition: .middle)
        } else {
            MapView()
        }
    }
}
#endif

extension MapView {
    fileprivate var refreshButton: some View {
        Button(
            action: viewModel.updateRegionStates,
            label: { Image(systemName: "arrow.clockwise") }
        )
        .padding(4)
        .contentShape(Rectangle())
    }
    
    fileprivate var fitUkraineButton: some View {
        Button(
            action: viewModel.fitUkraineBounds,
            label: { Image(systemName: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left") }
        )
        .padding(4)
        .contentShape(Rectangle())
    }
    
#if os(iOS)
    
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
            fitUkraineButton
            refreshButton
        }
    }
    
    fileprivate var regionListView: some View {
        VStack {
            regionListSectionHeader
            Divider()
            regionList
        }.padding([.top, .horizontal])
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
        ScrollView(bottomSheetPosition == .top ? .vertical : []) {
            VStack {
                ForEach(viewModel.alarmedRegion) { regionState in
                    RegionStateListItemView(regionState: regionState)
                        .contextMenu {
                            Text("item 1")
                            Text("Item 3")
                            Divider()
                            Text("Item 2")
                        }
                    Divider()
                }
                Spacer()
            }
        }
    }
    
#endif
}
