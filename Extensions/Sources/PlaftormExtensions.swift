//
//  PlaftormExtensions.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 21.04.2022.
//

import SwiftUI

#if os(iOS) || os(tvOS)
import UIKit
public typealias PlatformScreen = UIScreen
public typealias PlatformColor = UIColor
public typealias PlatformViewRepresentable = UIViewRepresentable
public typealias PlatformEdgeInsets = UIEdgeInsets
public typealias PlatformImage = UIImage
#elseif os(macOS)
import AppKit
public typealias PlatformScreen = NSScreen
public typealias PlatformColor = NSColor
public typealias PlatformViewRepresentable = NSViewRepresentable
public typealias PlatformEdgeInsets = NSEdgeInsets
public typealias PlatformImage = NSImage
#endif
