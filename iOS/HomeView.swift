//
//  MapView.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 20.04.2022.
//

import MapKit
import SwiftUI
import BottomSheet

struct HomeView: View {
    static let landscapeSheetWidthFraction = 1.0 / 7 * 3
    
    @LandscapeOrientation var isLandscape
    @State var bottomSheetPosition: BottomSheetPosition = .bottom
    @State var currentCoordinateRegion: MKCoordinateRegion = MapConstsants.boundsOfUkraine
    
    @StateObject private var viewModel = MapViewModel()
    
    var body: some View {
        GeometryReader { geometryProxy in
            ZStack(alignment: .topTrailing) {
                MapViewRepresentable(
                    coordinateRegion: $currentCoordinateRegion,
                    overlays: viewModel.overlays,
                    padding: getMapViewPadding(geometryProxy)
                ).ignoresSafeArea()
                toolbar
                Color.clear
                    .bottomSheet(
                        bottomSheetPosition: $bottomSheetPosition,
                        headerContent: { regionListHeader },
                        mainContent: { regionListView }
                    )
                    .padding(.trailing, getBottomSheetPadding(geometryProxy))
                    .offset(x: -geometryProxy.safeAreaInsets.leading / 2, y: 0)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            }
        }
        .onReceive(viewModel.$ukraineCoordinateRegion) {
            currentCoordinateRegion = $0
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15.0, *) {
            HomeView(bottomSheetPosition: .middle)
                .previewInterfaceOrientation(.landscapeLeft)
                .preferredColorScheme(.dark)
        } else {
            HomeView()
        }
    }
}

extension HomeView {
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
    
    
    fileprivate var shareButton: some View {
        HapticFeedbackButton(
            action: viewModel.shareMapSnapshot,
            label: { Image(systemName: "square.and.arrow.up").padding(12) }
        )
    }
    
    fileprivate var refreshButton: some View {
        HapticFeedbackButton(
            action: viewModel.reloadData,
            label: { Image(systemName: "arrow.clockwise").padding(12) }
        )
    }
    
    fileprivate var fitUkraineButton: some View {
        HapticFeedbackButton(
            action: viewModel.fitUkraineBounds,
            label: { Image(systemName: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left").padding(12) }
        )
    }
    
    fileprivate var regionListHeader: some View {
        HStack {
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
        }.padding([.top, .horizontal])
    }
    
    fileprivate var regionList: some View {
        ScrollView(bottomSheetPosition == .top ? .vertical : []) {
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
    }
    
    fileprivate func getBottomSheetLandscapeWidth(_ geometryProxy: GeometryProxy) -> CGFloat {
        return geometryProxy.size.width * HomeView.landscapeSheetWidthFraction
    }
    
    fileprivate func getBottomSheetPadding(_ geometryProxy: GeometryProxy) -> CGFloat {
        return isLandscape
            ? geometryProxy.size.width * (1 - HomeView.landscapeSheetWidthFraction)
            : 0
    }
    
    fileprivate func getMapViewPadding(_ geometryProxy: GeometryProxy) -> UIEdgeInsets {
        let size = geometryProxy.size
        
        let padding: UIEdgeInsets
        if bottomSheetPosition == .top || bottomSheetPosition == .middle {
            padding = isLandscape
                ? UIEdgeInsets(top: 0, left: geometryProxy.size.width * HomeView.landscapeSheetWidthFraction, bottom: 0, right: 0)
                : UIEdgeInsets(top: 0, left: 0, bottom: size.height * BottomSheetPosition.middle.rawValue, right: 0)
        } else {
            padding = .zero
        }
        
        return padding
    }
}
