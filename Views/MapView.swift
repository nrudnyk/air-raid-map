//
//  MapView.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 16.05.2022.
//

import MapKit
import SwiftUI
import Extensions
import CustomViews

struct MapView: View {
    @Environment(\.sizeCategory) var sizeCategory

    @AppStorage(wrappedValue: "", UserDefaults.Keys.lastUpdate, store: .standard)
    private var lastUpdate: String

#if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State var bottomSheetPosition: BottomSheetPosition = .bottom
#endif
    @State var imageToShare: PlatformImage? = nil
    @State var isPreparingSnapshot: Bool = false
    // TODO: should be replaced with viewModel's selected Region
    @State var focusedRegion: RegionStateModel? = nil
    @State var mapRegion: MKCoordinateRegion = MapConstsants.boundsOfUkraine
    @State var mapSize: CGSize = .zero
    @StateObject private var viewModel = MapViewModel()

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
            TabView {
                ZStack(alignment: .bottomTrailing) {
                    mapView(geometry: geometry)
                        .focusable(false)
                        .ignoresSafeArea()
                    refreshButton
                }
                .tabItem { Label(TabType.map.localizedTitle, systemImage: TabType.map.iconName) }
                .tag(TabType.map)

                HStack(spacing: 60) {
                    regionList

                    VStack {
                        regionListHeader
                        MapViewRepresentable(
                            coordinateRegion: .constant(getSelectedCoordinateRegion()),
                            overlays: viewModel.overlays
                        )
                        .focusable(false)
                        .clipShape(RoundedRectangle(cornerRadius: 40))
                    }
                }
                .tabItem { Label(TabType.regions.localizedTitle, systemImage: TabType.regions.iconName) }
                .tag(TabType.regions)
            }
#endif
        }
        .onAppear {
            DispatchQueue.main.async {
                mapRegion = regionWithPadding(MapConstsants.boundsOfUkraine)
            }
        }
    }
}

extension MapView {
    fileprivate func mapView(geometry: GeometryProxy) -> some View {
        MapViewRepresentable(
            coordinateRegion: $mapRegion,
            overlays: viewModel.overlays
        ).takeSize($mapSize)
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

#if os(iOS) || os(macOS)
    fileprivate var shareButton: some View {
        HapticFeedbackButton(
            action: {
                isPreparingSnapshot.toggle()
                MapWidgetSnapshotter.makeMapSnapshot(for: viewModel.overlays, size: mapSize) {
                    imageToShare = $0
                    isPreparingSnapshot.toggle()
                }
            },
            label: { Image(systemName: "square.and.arrow.up") }
        )
        .disabled(isPreparingSnapshot)
    }
#endif
    
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
            VStack(alignment: .leading) {
                HStack {
                    regionListHeaderTitle
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
        VStack {
            List {
                ForEach([AlertType.airAlarm, AlertType.allClear], id: \.self) { type in
                    Section {
                        ForEach(viewModel.regions.filtered(by: type)) { regionState in
                            regionListItem(regionState)
                                .focusable() { viewModel.selectedRegion = $0 ? regionState : nil }
                        }
                    } header: {
                        Label(type.rawValue.localized, systemImage: type.systemImage)
                    }
                    .headerProminence(.increased)
                }
            }
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
                    ForEach(viewModel.regions.filtered(by: viewModel.selectedAlertType)) { regionState in
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
#if !os(tvOS)
            focusOnRegion(item)
#endif
        }
    }

    func focusOnRegion(_ region: RegionStateModel) {
        focusedRegion = region
        mapRegion = regionWithPadding(MKCoordinateRegion(region.boudingRegion))
    }

    func regionWithPadding(_ region: MKCoordinateRegion) -> MKCoordinateRegion {
#if os(iOS)
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            if horizontalSizeClass == .compact && verticalSizeClass == .regular {
                return region.withVerticalPadding(bottomSheetPosition.rawValue)
            } else {
                return region.withHorizontalPadding(1 - BottomSheet.widthFraction)
            }
        case .pad:
            if bottomSheetPosition == .top {
                return region.withHorizontalPadding(1 - BottomSheet.widthFraction)
            }
        default:
            return region
        }
#endif
#if os(iOS) || os(macOS) || os(tvOS)
        return region
#endif
    }

    fileprivate var regionListHeaderTitle: Text {
        if let region = viewModel.selectedRegion {
            return Text(LocalizedStringKey(region.nameKey))
        } else {
            return Text("active_sirens")
        }
    }

    fileprivate func getSelectedCoordinateRegion() -> MKCoordinateRegion {
        if let region = viewModel.selectedRegion {
            return regionWithPadding(MKCoordinateRegion(region.boudingRegion))
        } else {
            return regionWithPadding(MapConstsants.boundsOfUkraine)
        }
    }
}

// MARK: iOS
#if os(iOS)
extension MapView {
    fileprivate var toolbar: some View {
        VStack(spacing: 0) {
            shareButton
                .popover(item: $imageToShare, attachmentAnchor: .rect(.bounds), arrowEdge: .leading, content: { image in
                    ShareActivityView(activityItems: [
                        ImageActivityItemSource(
                            title: "active_sirens".localized,
                            text: "\("as_of".localized) \(lastUpdate)",
                            image: image
                        )
                    ])
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
                // Portrait; if safeArea == 20 - it's phone with home button and rect screen
                return EdgeInsets(top: geometry.safeAreaInsets.top > 20 ? -8 : 0, leading: 0, bottom: 0, trailing: 8)
            } else {
                // Landscape; if safeArea == 0 - it's phone with home button and rect screen
                return EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: geometry.safeAreaInsets.trailing > 0 ? -8 : 8)
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

        ToolbarItem() {
            Menu {
                ForEach(NSSharingService.items, id: \.title) { item in
                    Button {
                        MapWidgetSnapshotter.makeMapSnapshot(
                            for: viewModel.overlays,
                            size: mapSize,
                            completion: { snapshot in item.perform(withItems: [snapshot]) }
                        )
                    } label: {
                        Image(nsImage: item.image)
                        Text(item.title)
                    }
                }
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
        }
    }
}

private func toggleSidebar() {
    NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
}
#endif

// MARK: tvOS

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            if #available(iOS 15.0, macOS 12.0, *) {
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
