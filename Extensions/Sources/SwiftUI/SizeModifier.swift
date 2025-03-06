//
//  SizeModifier.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 08.07.2022.
//

import SwiftUI

struct SizeModifier: ViewModifier {
    @Binding var size: CGSize

    init(_ size: Binding<CGSize>) {
        _size = size
    }

    func body(content: Content) -> some View {
        content.background(GeometryReader { proxy in
            Color.clear
                .preference(key: SizePreferenceKey.self, value: proxy.size)
                .onPreferenceChange(SizePreferenceKey.self) { self.size = $0 }
        })
    }
}

public extension View {
    func takeSize(_ size: Binding<CGSize>) -> some View {
        self.modifier(SizeModifier(size))
    }
}

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
