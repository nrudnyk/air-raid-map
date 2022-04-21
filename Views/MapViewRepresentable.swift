//
//  MapView.swift
//  air-raid-map (iOS)
//
//  Created by Nazar Rudnyk on 20.04.2022.
//
import SwiftUI
import MapKit
import Combine

public struct MapViewRepresentable: PlatformViewRepresentable {

    let mapType: MKMapType
    let isZoomEnabled: Bool
    let isScrollEnabled: Bool
    let userTrackingMode: MKUserTrackingMode
    let showsUserLocation: Bool
    
    @Binding var region: MKCoordinateRegion
    let overlays: [MKOverlay]
    
    
    public init(
        mapType: MKMapType = .standard,
        region: Binding<MKCoordinateRegion>,
        isZoomEnabled: Bool = true,
        isScrollEnabled: Bool = true,
        showsUserLocation: Bool = true,
        userTrackingMode: MKUserTrackingMode = .none,
        overlays: [MKOverlay] = []
    ) {
        self.mapType = mapType
        self._region = region
        self.isZoomEnabled = isZoomEnabled
        self.isScrollEnabled = isScrollEnabled
        self.showsUserLocation = showsUserLocation
        self.userTrackingMode = userTrackingMode
        self.overlays = overlays
    }

    public func makeCoordinator() -> MapViewRepresentable.Coordinator {
        return Coordinator(for: self)
    }
    
#if os(iOS) || os (tvOS)
    public func makeUIView(context: Context) -> MKMapView {
        return createMapView(context)
    }

    public func updateUIView(_ mapView: MKMapView, context: Context) {
        self.configureView(mapView, context: context)
    }
#elseif os(macOS)
    public func makeNSView(context: Context) -> MKMapView {
        return createMapView(context)
    }
    
    public func updateNSView(_ mapView: MKMapView, context: Context) {
        self.configureView(mapView, context: context)
    }
#endif

    private func createMapView(_ context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        self.configureView(mapView, context: context)
        
        return mapView
    }
    
    private func configureView(_ mapView: MKMapView, context: Context) {
        mapView.mapType = self.mapType
        
        let region = mapView.regionThatFits(self.region)
        if region.center.latitude != mapView.region.center.latitude ||
            region.center.longitude != mapView.region.center.longitude ||
            region.span.latitudeDelta != mapView.region.span.latitudeDelta ||
            region.span.longitudeDelta != mapView.region.span.longitudeDelta {
            mapView.setRegion(region, animated: true)
        }
#if os(macOS)
        mapView.setRegion(region, animated: true)
#endif
        
        mapView.isZoomEnabled = self.isZoomEnabled
        mapView.isScrollEnabled = self.isScrollEnabled
        mapView.showsUserLocation = self.showsUserLocation
        mapView.userTrackingMode = self.userTrackingMode
        
        self.updateOverlays(in: mapView)
    }
    
    private func updateOverlays(in mapView: MKMapView) {
        let currentOverlays = mapView.overlays
        
        let obsoleteOverlays = currentOverlays.filter { overlay in
            !self.overlays.contains { $0.isEqual(overlay) }
        }
        mapView.removeOverlays(obsoleteOverlays)
        
        let newOverlays = self.overlays.filter { overlay in
            !currentOverlays.contains { $0.isEqual(overlay) }
        }
        mapView.addOverlays(newOverlays)
    }
    
    // MARK: - Interaction and delegate implementation
    public class Coordinator: NSObject, MKMapViewDelegate {
        
        /**
         Reference to the SwiftUI `MapView`.
        */
        private let context: MapViewRepresentable
        
        init(for context: MapViewRepresentable) {
            self.context = context
            super.init()
        }
                
        public func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            DispatchQueue.main.async {
                self.context.region = mapView.region
            }
        }
        
        public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let regionOverlay = overlay as? RegionOverlay
            else {
                return MKOverlayRenderer(overlay: overlay)
            }
            
            return regionOverlay.getOverlayRenderer()
        }
    }
    
}

#if DEBUG
// MARK: - SwiftUI Preview
struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
#endif



//struct MapViewRepresentable_Previews: PreviewProvider {
//    static var previews: some View {
//        MapViewRepresentable(
//            region: .constant(MKCoordinateRegion(center: CLLocationCoordinate2D.centerOfUkraine, span: MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2))),
//            overlays: .constant([])
//        )
//    }
//}