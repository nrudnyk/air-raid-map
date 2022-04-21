//
//  MapView.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 20.04.2022.
//

import MapKit
import SwiftUI

struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    
    var body: some View {
        
//        SwiftUIMapView.MapView(region: $viewModel.region)
//        Map(coordinateRegion: $viewModel.region)
        MapViewRepresentable(region: $viewModel.region, overlays: viewModel.overlays)
            .ignoresSafeArea()
    }
}

//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapViewRepresentable(
//            region: .constant(MKCoordinateRegion(center: CLLocationCoordinate2D.centerOfUkraine, span: MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2))),
//            overlays: .constant([])
//        )
//            .ignoresSafeArea()
//    }
//}
