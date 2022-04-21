//
//  RegionModel.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 20.04.2022.
//

import MapKit

class Region: Feature<Region.Properties> {
    struct Properties: Codable {
        let fid: Int
        let region: String
    }
}

class RegionOverlay: NSObject, MKOverlay {
    let coordinate: CLLocationCoordinate2D
    let boundingMapRect: MKMapRect
    let color: PlatformColor
    
    private let shape: MKShape & MKGeoJSONObject
    private let overlay: MKOverlay
    
    init(shape: MKShape & MKGeoJSONObject, color: PlatformColor) {
        self.shape = shape
        self.overlay = shape as! MKOverlay
        
        self.coordinate = overlay.coordinate
        self.boundingMapRect = overlay.boundingMapRect
        self.color = color
    }
    
    public func getOverlayRenderer() -> MKOverlayRenderer {
        let renderer: MKOverlayPathRenderer
        switch overlay {
        case is MKMultiPolygon:
            renderer = MKMultiPolygonRenderer(overlay: overlay)
        case is MKPolygon:
            renderer = MKPolygonRenderer(overlay: overlay)
        case is MKMultiPolyline:
            renderer = MKMultiPolylineRenderer(overlay: overlay)
        case is MKPolyline:
            renderer = MKPolylineRenderer(overlay: overlay)
        default:
            return MKOverlayRenderer(overlay: overlay)
        }
        
        renderer.fillColor = self.color.withAlphaComponent(0.5)
        renderer.strokeColor = self.color.withAlphaComponent(0.1)
        renderer.lineWidth = 1
        
        return renderer
    }
}
