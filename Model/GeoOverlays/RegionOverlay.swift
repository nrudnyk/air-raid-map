//
//  RegionOverlay.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 21.04.2022.
//

import MapKit

class RegionOverlay: NSObject, MKOverlay {
    let coordinate: CLLocationCoordinate2D
    let boundingMapRect: MKMapRect
    let color: PlatformColor
    
    private let shape: MKShape & MKGeoJSONObject
    private let overlay: MKOverlay
   
    convenience init(regionStateModel: RegionStateModel) {
        self.init(shape: regionStateModel.geometry, color: regionStateModel.alertState.type.color)
    }
    
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
        
        renderer.fillColor = self.color
        renderer.strokeColor = self.color.withAlphaComponent(0.2)
        renderer.lineWidth = 1
        
        return renderer
    }
    
    public func tryDrawOverlay(in context: CGContext, to snapshot: MKMapSnapshotter.Snapshot) {
        context.setStrokeColor(self.color.withAlphaComponent(0.2).cgColor)
        context.setFillColor(self.color.cgColor)
        context.setLineWidth(1.0)

        let renderer = getOverlayRenderer()
        switch renderer {
        case is MKMultiPolygonRenderer:
            let polygons = (renderer as! MKMultiPolygonRenderer).multiPolygon.polygons
            for polygon in polygons {
                tryDraw(polygon, in: context, with: snapshot)
            }
        case is MKPolygonRenderer:
            let polygon = (renderer as! MKPolygonRenderer).polygon
            tryDraw(polygon, in: context, with: snapshot)
        default:
            return
        }
    }
    
    private func tryDraw(_ polygon: MKPolygon, in context: CGContext, with snapshot: MKMapSnapshotter.Snapshot) {
        if polygon.pointCount < 2 { return }

        context.beginPath()
        
        let coordinates = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: polygon.pointCount)
        polygon.getCoordinates(coordinates, range: NSRange(location: 0, length: polygon.pointCount))
        
        let buffer = UnsafeBufferPointer(start: coordinates, count: polygon.pointCount)
        context.move(to: snapshot.point(for: buffer[0]))
        
        for i in 1 ..< buffer.count {
            let point = snapshot.point(for: buffer[i])
            context.addLine(to: point)
        }
        
        context.closePath()
        context.fillPath()
    }
}
