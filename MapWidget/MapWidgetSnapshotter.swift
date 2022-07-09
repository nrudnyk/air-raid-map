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

    static func makeMapSnapshots(for regionOverlays: [RegionOverlay], size: CGSize, completion: @escaping ([ColorScheme: PlatformImage]) -> Void) {
        let concurrentQueue = DispatchQueue(label: "com.nrudnyk.snapshotter.queue", attributes: .concurrent)
        let dispatchGroup = DispatchGroup()

        dispatchGroup.enter()
        var lightSnapshot: PlatformImage?
        let lightSnapshotter = makeMapSnapshotter(coordinateRegion: MapConstsants.boundsOfUkraine, size: size, colorScheme: .light)
        lightSnapshotter.start(with: concurrentQueue) { snapshot, error in
            lightSnapshot = tryMakeMapSnapshot(snapshot, regionOverlays: regionOverlays)
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        var darkSnapshot: PlatformImage?
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
    
    static func makeMapSnapshot(for regionOverlays: [RegionOverlay], size: CGSize, completion: @escaping (PlatformImage) -> Void) {
        let snapsnotter = makeMapSnapshotter(coordinateRegion: MapConstsants.boundsOfUkraine, size: size)
        snapsnotter.start { snapshot, error in
            if let snapshot = tryMakeMapSnapshot(snapshot, regionOverlays: regionOverlays) {
                completion(snapshot)
            }
        }
    }
    
    private static func tryMakeMapSnapshot(_ snapshot: MKMapSnapshotter.Snapshot?, regionOverlays: [RegionOverlay]) -> PlatformImage? {
        guard let snapshot = snapshot else { return nil }
        let image = snapshot.image

        let resultImage: PlatformImage?
        #if os(iOS)
        UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
        image.draw(at: .zero)
        if let context = UIGraphicsGetCurrentContext() {
            for overlay in regionOverlays {
                overlay.tryDrawOverlay(in: context, to: snapshot)
            }
        }
        let imageWithOverlays = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        resultImage = imageWithOverlays
        #elseif os(macOS)
        image.lockFocus()
        if let context = NSGraphicsContext.current?.cgContext {
            for overlay in regionOverlays {
                overlay.tryDrawOverlay(in: context, to: snapshot)
            }
        }
        image.unlockFocus()

        resultImage = image
        #endif

        return resultImage
    }

    static func makeMapSnapshotter(coordinateRegion: MKCoordinateRegion, size: CGSize, colorScheme: ColorScheme? = nil) -> MKMapSnapshotter {
        let options = MKMapSnapshotter.Options()
        options.region = coordinateRegion
        options.size = size
        if let colorScheme = colorScheme {
#if os(iOS)
            options.traitCollection = UITraitCollection(
                traitsFrom: [options.traitCollection, UITraitCollection(userInterfaceStyle: colorScheme.userInterfaceStyle)]
            )
#elseif os(macOS)
            options.appearance = colorScheme.appearance
#endif
        }

        return MKMapSnapshotter(options: options)
    }
}
