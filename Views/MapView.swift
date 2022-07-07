//
//  MapView.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 16.05.2022.
//

import MapKit
import SwiftUI

struct MapView: View {
    @Environment(\.sizeCategory) var sizeCategory
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    @AppStorage(wrappedValue: "", UserDefaults.Keys.lastUpdate, store: .standard)
    private var lastUpdate: String

#if os(iOS)
    @LandscapeOrientation var isLandscape
    @State var bottomSheetPosition: BottomSheetPosition = .middle
    @State private var imageActivityItemSource: ImageActivityItemSource? = nil
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
                    .padding(toolbarPadding(with: geometry))
                bottomSheet(geometryProxy: geometry)
            }
#elseif os(macOS)
            NavigationView {
                regionListView
                    .padding([.horizontal])
                    .toolbar { sidebarToolbar }
                    .frame(minWidth: 250)
                ZStack(alignment: .topTrailing) {
                    mapView(geometry: geometry)
                        .navigationTitle("")
                        .toolbar { toolbar }
                    reachabilityLabel
                        .shadow(radius: 10)
                        .padding()
                }.animation(.linear(duration: 0.4), value: viewModel.isNetworkReachable)
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

extension MapView {
    fileprivate func mapView(geometry: GeometryProxy) -> some View {
        MapViewRepresentable(
            coordinateRegion: $mapRegion,
            overlays: viewModel.overlays
        )
    }

    @ViewBuilder
    fileprivate var reachabilityLabel: some View {
        if !viewModel.isNetworkReachable {
            Label("offline", systemImage: "antenna.radiowaves.left.and.right.slash")
                .transition(.scale(scale: 1.1).combined(with: .opacity))
        } else {
            EmptyView()
        }
    }

    fileprivate var shareButton: some View {
        HapticFeedbackButton(
            action: {
                MapWidgetSnapshotter.makeMapSnapshot(for: viewModel.overlays, size: CGSize(width: 800, height: 600)) { snapshot in
                    imageActivityItemSource = ImageActivityItemSource(
                        title: viewModel.activeAlarmsTitle,
                        text: "\("as_of".localized) \(lastUpdate)",
                        image: snapshot
                    )
                }
            },
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
            action: { mapRegion = regionWithPadding(MapConstsants.boundsOfUkraine) },
            label: { Image(systemName: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left") }
        )
    }

    fileprivate var regionListHeader: some View {
        HStack {
#if os(tvOS)
            sidebarButton
#endif
            VStack(alignment: .leading) {
                HStack {
                    Text(viewModel.activeAlarmsTitle)
                        .font(.title3).bold()
                    Spacer()
#if os(iOS)
                    reachabilityLabel
                        .font(.footnote)
#endif
                }
                .animation(.linear(duration: 0.4), value: viewModel.isNetworkReachable)
                
                HStack(alignment: .top, spacing: 0) {
                    if sizeCategory < .accessibilityExtraLarge {
                        Text("as_of")
                            .italic()
                            .font(.subheadline)
                        Text(" ")
                    }
                    Text(lastUpdate)
                        .italic()
                        .font(.subheadline)
                        .transition(.scale(scale: 1.1).combined(with: .opacity))
                        .id(lastUpdate)
                }
                .animation(.linear(duration: 0.4), value: lastUpdate)
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
        List(viewModel.regions) { regionState in
            regionListItem(regionState)
        }
#else
        VStack {
            Picker("", selection: $viewModel.selectedAlertType) {
                ForEach(AlertType.allCases, id: \.self) { type in
                    Image(systemName: type.systemImage)
                }
            }
            .pickerStyle(.segmented)

            ScrollView() {
                VStack {
                    ForEach(viewModel.regions) { regionState in
                        regionListItem(regionState)
                        Divider()
                    }
                    Spacer()
                }
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
#if os(iOS)
        return isLandscape
            ? region.withHorizontalPadding(BottomSheet.widthFraction)
            : region.withVerticalPadding(bottomSheetPosition.rawValue)
#elseif os(macOS) || os(tvOS)
        return region
#endif
    }
}

// MARK: iOS
#if os(iOS)
extension MapView {
    fileprivate var toolbar: some View {
        VStack(spacing: 0) {
            shareButton
                .popover(item: $imageActivityItemSource, attachmentAnchor: .rect(.bounds), arrowEdge: .leading, content: { item in
                    ShareSheet(activityItems: [item])
                        .ignoresSafeArea()
                })
            Divider()
            fitUkraineButton
            Divider()
            refreshButton
        }
        .fixedSize(horizontal: true, vertical: false)
        .background(EffectView(effect: UIBlurEffect(style: .systemThinMaterial)))
        .foregroundColor(Color.secondary)
        .cornerRadius(8)
    }

    fileprivate func toolbarPadding(with geometry: GeometryProxy) -> EdgeInsets {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            if horizontalSizeClass == .compact && verticalSizeClass == .regular {
                return EdgeInsets(top: -8, leading: 0, bottom: 0, trailing: 8)
            } else {
                return EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: -8)
            }
        case .pad:
            return EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 8)
        default:
            return .zero
        }
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

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            if #available(iOS 15.0, *) {
                MapView()
                    .previewInterfaceOrientation(.landscapeLeft)
            } else {
                MapView()
            }
        }
        .preferredColorScheme(.dark)
        .environment(\.sizeCategory, .accessibilityExtraExtraLarge)
        .environment(\.locale, .init(identifier: "uk"))
    }
}
