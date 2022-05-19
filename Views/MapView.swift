//
//  MapView.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 16.05.2022.
//

import MapKit
import SwiftUI

struct MapView: View {
#if os(iOS)
    @LandscapeOrientation var isLandscape
    @State var bottomSheetPosition: BottomSheetPosition = .bottom
#elseif os(tvOS)
    @State private var isSidebarVisible = false
#endif
    
    @State var mapRegion: MKCoordinateRegion = MapConstsants.boundsOfUkraine
    
    @StateObject private var viewModel = MapViewModel()
    
    var body: some View {
        GeometryReader { geometryProxy in
#if os(iOS)
            ZStack(alignment: .topTrailing) {
                mapView(geometryProxy: geometryProxy)
                    .ignoresSafeArea()
                toolbar
                bottomSheet(geometryProxy: geometryProxy)
            }
            .onChange(of: bottomSheetPosition) { newValue in
                viewModel.refreshCoordinateRegion()
            }
#elseif os(macOS)
            NavigationView {
                regionListView
                    .padding([.horizontal])
                    .toolbar { sidebarToolbar }
                    .frame(minWidth: 250)
                mapView(geometryProxy: geometryProxy)
                    .navigationTitle("")
                    .toolbar { toolbar }
            }
#elseif os(tvOS)
            ZStack(alignment: .topTrailing) {
                HStack {
                    if (isSidebarVisible) { sidebar }
                    ZStack(alignment: .topTrailing) {
                        mapView(geometryProxy: geometryProxy)
                            .focusable(false)
                            .ignoresSafeArea()
                        toolbar
                    }.focusSection()
                }
            }
#endif
        }
        .onReceive(viewModel.$currentMapRegion) {
            mapRegion = $0
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
#if os(iOS)
        if #available(iOS 15.0, *) {
            MapView(bottomSheetPosition: .middle)
                .previewInterfaceOrientation(.landscapeLeft)
                .preferredColorScheme(.dark)
        } else {
            MapView()
        }
#else
        MapView()
#endif
    }
}

extension MapView {
    fileprivate func mapView(geometryProxy: GeometryProxy) -> some View {
        MapViewRepresentable(
            coordinateRegion: $mapRegion,
            overlays: viewModel.overlays,
            padding: getMapViewPadding(geometryProxy)
        )
    }
    
    fileprivate var shareButton: some View {
        HapticFeedbackButton(
            action: viewModel.shareMapSnapshot,
            label: { Image(systemName: "square.and.arrow.up") }
        )
    }
    
    fileprivate var refreshButton: some View {
        HapticFeedbackButton(
            action: viewModel.reloadData,
            label: { Image(systemName: "arrow.clockwise") }
        )
    }
    
    fileprivate var fitUkraineButton: some View {
        HapticFeedbackButton(
            action: viewModel.fitUkraineBounds,
            label: { Image(systemName: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left") }
        )
    }
    
    fileprivate var regionListHeader: some View {
        HStack {
#if os(tvOS)
            sidebarButton
#endif
            VStack(alignment: .leading) {
                Text(viewModel.activeAlarmsTitle)
                    .font(.title3).bold()
                Text(viewModel.activeAlarmsSubtitle)
                    .italic()
                    .font(.subheadline)
                    .frame(alignment: .trailing)
            }
            Spacer()
        }
    }
    
    fileprivate var regionListView: some View {
        VStack {
            Divider()
            regionList
        }
    }
    
    fileprivate var regionList: some View {
#if os(tvOS)
        List(viewModel.alarmedRegions) { regionState in
            RegionStateListItemView(regionState) {
                viewModel.focusOnRegion(regionState)
            }
        }
#else
        ScrollView() {
            VStack {
                ForEach(viewModel.alarmedRegions) { regionState in
                    RegionStateListItemView(regionState) {
                        viewModel.focusOnRegion(regionState)
                    }
                    Divider()
                }
                Spacer()
            }
        }
#endif
    }
    
    fileprivate func getMapViewPadding(_ geometryProxy: GeometryProxy) -> PlatformEdgeInsets {
#if os(iOS)
        if bottomSheetPosition == .top || bottomSheetPosition == .middle {
            return isLandscape
                ? UIEdgeInsets(top: 0, left: geometryProxy.size.width * MapView.landscapeSheetWidthFraction, bottom: 0, right: 0)
                : UIEdgeInsets(top: 0, left: 0, bottom: geometryProxy.size.height * BottomSheetPosition.middle.rawValue, right: 0)
        }
#endif
        
        return .zero
    }
}

#if os(iOS)
extension MapView {
    static let landscapeSheetWidthFraction = 1.0 / 7 * 3
    
    fileprivate var toolbar: some View {
        VStack(spacing: 0) {
            shareButton
            Divider()
            fitUkraineButton
            Divider()
            refreshButton
        }
        .fixedSize(horizontal: true, vertical: false)
        .background(Color(.secondarySystemBackground))
        .foregroundColor(Color.secondary)
        .cornerRadius(8)
        .padding(.top, isLandscape ? 8 : -8)
        .padding(.trailing, isLandscape ? -8 : 8)
    }
    
    fileprivate func bottomSheet(geometryProxy: GeometryProxy) -> some View {
        Color.clear
            .bottomSheet(
                bottomSheetPosition: $bottomSheetPosition,
                headerContent: {
                    regionListHeader.padding([.bottom])
                },
                mainContent: {
                    regionListView.padding([.horizontal])
                }
            )
            .padding(.trailing, getBottomSheetPadding(geometryProxy))
            .offset(x: -geometryProxy.safeAreaInsets.leading / 2, y: 0)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
    
    fileprivate func getBottomSheetLandscapeWidth(_ geometryProxy: GeometryProxy) -> CGFloat {
        return geometryProxy.size.width * MapView.landscapeSheetWidthFraction
    }
    
    fileprivate func getBottomSheetPadding(_ geometryProxy: GeometryProxy) -> CGFloat {
        return isLandscape
            ? geometryProxy.size.width * (1 - MapView.landscapeSheetWidthFraction)
            : 0
    }
}
#endif

#if os(macOS)
extension MapView {
    @ToolbarContentBuilder
    fileprivate var sidebarToolbar: some ToolbarContent {
        ToolbarItem(placement: .status) {
            Button(action: toggleSidebar, label: {
                Image(systemName: "sidebar.leading")
            })
        }
    }

    @ToolbarContentBuilder
    fileprivate var toolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .navigation) {
            regionListHeader
        }
        ToolbarItem(placement: .confirmationAction) {
            fitUkraineButton
        }
        ToolbarItem(placement: .confirmationAction) {
            refreshButton
        }
    }
}

private func toggleSidebar() {
    NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
}
#endif

#if os(tvOS)
extension MapView {
    fileprivate var sidebar: some View {
        VStack {
            regionListHeader
            regionListView
                .frame(maxWidth: 750)
                .focusSection()
        }
    }
    
    fileprivate var sidebarButton: some View {
        Button(
            action: { withAnimation { isSidebarVisible.toggle() }},
            label: { Image(systemName: "sidebar.leading") }
        )
    }
    
    fileprivate var toolbar: some View {
        HStack(alignment: .top) {
            if (!isSidebarVisible) { sidebarButton }
            Spacer()
            VStack() {
                fitUkraineButton
                refreshButton
            }
        }
    }
}
#endif
