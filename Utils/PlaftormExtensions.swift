//
//  PlaftormExtensions.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 21.04.2022.
//

import SwiftUI

#if os(iOS) || os(tvOS)
import UIKit
typealias PlatformColor = UIColor
typealias PlatformViewRepresentable = UIViewRepresentable
#elseif os(macOS)
import AppKit
typealias PlatformColor = NSColor
typealias PlatformViewRepresentable = NSViewRepresentable
#endif
