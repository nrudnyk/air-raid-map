//
//  MapWidgetSnapshotter.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 01.05.2022.
//

import Foundation
import WidgetKit
import SwiftUI
import MapKit

class MapWidgetSnapshotter {

    static func makeMapSnapshots(for regionOverlays: [RegionOverlay], size: CGSize, completion: @escaping ([ColorScheme: UIImage]) -> Void) {
        let concurrentQueue = DispatchQueue(label: "com.nrudnyk.snapshotter.queue", attributes: .concurrent)
        let dispatchGroup = DispatchGroup()

        dispatchGroup.enter()
        var lightSnapshot: UIImage?
        let lightSnapshotter = makeMapSnapshotter(coordinateRegion: MapConstsants.boundsOfUkraine, size: size, colorScheme: .light)
        lightSnapshotter.start(with: concurrentQueue) { snapshot, error in
            lightSnapshot = tryMakeMapSnapshot(snapshot, regionOverlays: regionOverlays)
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        var darkSnapshot: UIImage?
        let darkSnapshotter = makeMapSnapshotter(coordinateRegion: MapConstsants.boundsOfUkraine, size: size, colorScheme: .dark)
        darkSnapshotter.start(with: concurrentQueue) { snapshot, error in
            darkSnapshot = tryMakeMapSnapshot(snapshot, regionOverlays: regionOverlays)
            dispatchGroup.leave()
        }

        DispatchQueue.main.async {
            dispatchGroup.wait()
            
            if let lightSnapshot = lightSnapshot, let darkSnapshot = darkSnapshot {
                completion([
                    .light: lightSnapshot,
                    .dark: darkSnapshot
                ])
            }
        }
    }
    
    private static func tryMakeMapSnapshot(_ snapshot: MKMapSnapshotter.Snapshot?, regionOverlays: [RegionOverlay]) -> UIImage? {
        guard let snapshot = snapshot else { return nil }
        
        let image = snapshot.image
        UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
        image.draw(at: .zero)
        
        if let context = UIGraphicsGetCurrentContext() {
            for overlay in regionOverlays {
                overlay.tryDrawOverlay(in: context, to: snapshot)
            }
        }
        let imageWithOverlays = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return imageWithOverlays
    }
    
    static func makeMapSnapshotter(coordinateRegion: MKCoordinateRegion, size: CGSize, colorScheme: UIUserInterfaceStyle) -> MKMapSnapshotter {
        let options = MKMapSnapshotter.Options()
        options.region = coordinateRegion
        options.size = size
        options.traitCollection = UITraitCollection(traitsFrom: [options.traitCollection, UITraitCollection(userInterfaceStyle: colorScheme)])
        
        return MKMapSnapshotter(options: options)
    }
}
