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
    
    let showScale: Bool
    
    @Binding var coordinateRegion: MKCoordinateRegion
    let overlays: [MKOverlay]
    
    let padding: PlatformEdgeInsets
    
    public init(
        mapType: MKMapType = .standard,
        coordinateRegion: Binding<MKCoordinateRegion>,
        isZoomEnabled: Bool = true,
        isScrollEnabled: Bool = true,
        showsUserLocation: Bool = false,
        showScale: Bool = true,
        userTrackingMode: MKUserTrackingMode = .none,
        overlays: [MKOverlay] = [],
        padding: PlatformEdgeInsets = .zero
    ) {
        self.mapType = mapType
        self._coordinateRegion = coordinateRegion
        self.isZoomEnabled = isZoomEnabled
        self.isScrollEnabled = isScrollEnabled
        self.showsUserLocation = showsUserLocation
        self.showScale = showScale
        self.userTrackingMode = userTrackingMode
        self.overlays = overlays
        self.padding = padding
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
                
        if coordinateRegion.center.latitude != mapView.region.center.latitude ||
            coordinateRegion.center.longitude != mapView.region.center.longitude ||
            coordinateRegion.span.latitudeDelta != mapView.region.span.latitudeDelta ||
            coordinateRegion.span.longitudeDelta != mapView.region.span.longitudeDelta {
            DispatchQueue.main.async {
                mapView.setCoordinateRegion(coordinateRegion, edgePadding: self.padding, animated: true)
            }
        }
        
        mapView.isZoomEnabled = self.isZoomEnabled
        mapView.isScrollEnabled = self.isScrollEnabled
        mapView.showsUserLocation = self.showsUserLocation
#if !os(tvOS)
        mapView.isRotateEnabled = false
        mapView.showsCompass = false
#endif
        mapView.userTrackingMode = self.userTrackingMode
#if os(iOS) || os (tvOS)
        mapView.showsScale = true
#elseif os(macOS)
        mapView.showsZoomControls = true
#endif
        
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
