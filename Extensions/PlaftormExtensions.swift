//
//  PlaftormExtensions.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 21.04.2022.
//

import SwiftUI

#if os(iOS) || os(tvOS)
import UIKit
typealias PlatformScreen = UIScreen
typealias PlatformColor = UIColor
typealias PlatformViewRepresentable = UIViewRepresentable
public typealias PlatformEdgeInsets = UIEdgeInsets
typealias PlatformImage = UIImage
#elseif os(macOS)
import AppKit
typealias PlatformScreen = NSScreen
typealias PlatformColor = NSColor
typealias PlatformViewRepresentable = NSViewRepresentable
public typealias PlatformEdgeInsets = NSEdgeInsets
typealias PlatformImage = NSImage
#endif
