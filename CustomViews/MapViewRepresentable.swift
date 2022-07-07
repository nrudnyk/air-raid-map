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
    let userTrackingMode: MKUserTrackingMode
    let showsUserLocation: Bool
    
    @Binding var coordinateRegion: MKCoordinateRegion
    let overlays: [MKOverlay]
    
    public init(
        mapType: MKMapType = .standard,
        coordinateRegion: Binding<MKCoordinateRegion>,
        showsUserLocation: Bool = false,
        userTrackingMode: MKUserTrackingMode = .none,
        overlays: [MKOverlay] = []
    ) {
        self.mapType = mapType
        self._coordinateRegion = coordinateRegion
        self.showsUserLocation = showsUserLocation
        self.userTrackingMode = userTrackingMode
        self.overlays = overlays
    }

    public func makeCoordinator() -> MapViewRepresentable.Coordinator {
        return Coordinator(for: self)
    }
    
#if os(iOS) || os(tvOS)
    public func makeUIView(context: Context) -> MKMapView {
        return createMapView(context)
    }

    public func updateUIView(_ mapView: MKMapView, context: Context) {
        self.updateMapView(mapView, context: context)
    }
#elseif os(macOS)
    public func makeNSView(context: Context) -> MKMapView {
        return createMapView(context)
    }
    
    public func updateNSView(_ mapView: MKMapView, context: Context) {
        self.updateMapView(mapView, context: context)
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

#if os(iOS) || os (tvOS)
        mapView.showsScale = true
#elseif os(macOS)
        mapView.showsZoomControls = true
#endif
        
#if os(tvOS)
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
#else
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        mapView.isRotateEnabled = false
        mapView.showsCompass = false
#endif
        
        mapView.showsUserLocation = self.showsUserLocation
        mapView.userTrackingMode = self.userTrackingMode

        mapView.setRegion(coordinateRegion, animated: true)
        self.updateOverlays(in: mapView)
    }
    
    private func updateMapView(_ mapView: MKMapView, context: Context) {
        if coordinateRegion != mapView.region {
            DispatchQueue.main.async {
                mapView.setRegion(coordinateRegion, animated: true)
            }
        }

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
    
    public class Coordinator: NSObject, MKMapViewDelegate {
        private let context: MapViewRepresentable
        
        init(for context: MapViewRepresentable) {
            self.context = context
            super.init()
        }
        
        public func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            self.context.coordinateRegion = mapView.region
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
struct MapViewRepresentable_Previews: PreviewProvider {
    static var previews: some View {
        MapViewRepresentable(
            coordinateRegion: .constant(MKCoordinateRegion(center: MapConstsants.centerOfUkraine, span: MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)))
        )
    }
}
#endif
