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
    @State var focusedRegion: RegionStateModel? = nil
    @State var mapRegion: MKCoordinateRegion = MapConstsants.boundsOfUkraine
    @StateObject private var viewModel = MapViewModel()

    init() {
        mapRegion = regionWithPadding(MapConstsants.boundsOfUkraine)
    }

    var body: some View {
        GeometryReader { geometry in
#if os(iOS)
            ZStack(alignment: .topTrailing) {
                mapView(geometry: geometry)
                    .ignoresSafeArea()
                toolbar
                bottomSheet(geometryProxy: geometry)
            }
#elseif os(macOS)
            NavigationView {
                regionListView
                    .padding([.horizontal])
                    .toolbar { sidebarToolbar }
                    .frame(minWidth: 250)
                mapView(geometry: geometry)
                    .navigationTitle("")
                    .toolbar { toolbar }
            }
#elseif os(tvOS)
            ZStack(alignment: .topTrailing) {
                HStack {
                    if (isSidebarVisible) { sidebar }
                    ZStack(alignment: .topTrailing) {
                        mapView(geometry: geometry)
                            .focusable(false)
                            .ignoresSafeArea()
                        toolbar
                    }.focusSection()
                }
            }
#endif
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
#if os(iOS)
        if #available(iOS 15.0, *) {
            MapView()
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
    fileprivate func mapView(geometry: GeometryProxy) -> some View {
        MapViewRepresentable(
            coordinateRegion: $mapRegion,
            overlays: viewModel.overlays
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
            action: {
                mapRegion = regionWithPadding(MapConstsants.boundsOfUkraine)
            },
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
            regionListItem(regionState)
        }
#else
        ScrollView() {
            VStack {
                ForEach(viewModel.alarmedRegions) { regionState in
                    regionListItem(regionState)
                    Divider()
                }
                Spacer()
            }
        }
#endif
    }
    
    fileprivate func regionListItem(_ item: RegionStateModel) -> some View {
        RegionStateListItemView(item) {
#if os(iOS)
            bottomSheetPosition = .middle
#endif
            focusOnRegion(item)
        }
    }

    func focusOnRegion(_ region: RegionStateModel) {
        focusedRegion = region
        mapRegion = regionWithPadding(MKCoordinateRegion(region.boudingRegion))
    }

    func regionWithPadding(_ region: MKCoordinateRegion) -> MKCoordinateRegion {
        return isLandscape
            ? region.withHorizontalPadding(BottomSheet.widthFraction)
            : region.withVerticalPadding(bottomSheetPosition.rawValue)
    }
}

// MARK: iOS
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
        .background(EffectView(effect: UIBlurEffect(style: .systemThinMaterial)))
        .foregroundColor(Color.secondary)
        .cornerRadius(8)
        .padding(.top, isLandscape ? 8 : -8)
        .padding(.trailing, isLandscape ? -8 : 8)
    }
    
    fileprivate func bottomSheet(geometryProxy: GeometryProxy) -> some View {
        BottomSheetView(
            bottomSheetPosition: $bottomSheetPosition,
            headerContent: {
                regionListHeader.padding([.bottom])
            },
            mainContent: {
                regionListView.padding([.horizontal])
            }
        )
    }
    
    fileprivate func getBottomSheetLandscapeWidth(_ geometryProxy: GeometryProxy) -> CGFloat {
        return geometryProxy.size.width * MapView.landscapeSheetWidthFraction
    }
}
#endif

// MARK: macOS
#if os(macOS)
extension MapView {
    @ToolbarContentBuilder
    fileprivate var sidebarToolbar: some ToolbarContent {
        ToolbarItem() {
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
        ToolbarItem() {
            fitUkraineButton
        }
        ToolbarItem() {
            refreshButton
        }
    }
}

private func toggleSidebar() {
    NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
}
#endif

// MARK: tvOS
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
