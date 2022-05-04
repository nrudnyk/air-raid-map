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
    @LandscapeOrientation var isLandscape
    @State var bottomSheetPosition: BottomSheetPosition = .bottom
    
    @StateObject private var viewModel = MapViewModel()
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            MapViewRepresentable(
                region: $viewModel.ukraineCoordinateRegion,
                overlays: viewModel.overlays
            ).ignoresSafeArea()
            toolbar
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
    
    fileprivate var refreshButton: some View {
        Button(
            action: {
                viewModel.reloadData()
                selectionHapticFeedback()
            },
            label: {
                Image(systemName: "arrow.clockwise")
                    .padding(12)
            }
        )
    }
    
    fileprivate var fitUkraineButton: some View {
        Button(
            action: {
                viewModel.fitUkraineBounds()
                selectionHapticFeedback()
            },
            label: {
                Image(systemName: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left")
                    .padding(12)
            }
        )
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
    
    fileprivate var regionListView: some View {
        VStack {
            Divider()
            regionList
        }.padding([.top, .horizontal])
    }
    
    fileprivate var regionList: some View {
        ScrollView(bottomSheetPosition == .top ? .vertical : []) {
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