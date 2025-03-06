//
//  HapticFeedbackButton.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 16.05.2022.
//

import SwiftUI

public struct HapticFeedbackButton<Label: View>: View {
#if os(iOS)
    private let defaultPadding = 12.0
#else
    private let defaultPadding = 0.0
#endif
    
#if os(iOS)
    private let hapticFeedbacGenerator = UINotificationFeedbackGenerator()
    
    let feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle
#endif
    let action: () -> Void
    let label: () -> Label
    
#if os(iOS)
    public init(
        action: @escaping () -> Void,
        label: @escaping () -> Label,
        feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle = .light
    ) {
        self.feedbackStyle = feedbackStyle
        self.action = action
        self.label = label
    }
#else
    public init(action: @escaping () -> Void, label: @escaping () -> Label) {
        self.action = action
        self.label = label
    }
#endif
    
    public var body: some View {
        Button(
            action: {
#if os(iOS)
                UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred()
#endif
                action()
            },
            label: {
                label()
                    .padding(defaultPadding)
                    .contentShape(Rectangle())
            }
        )
    }
}

struct HapticFeedbackButton_Previews: PreviewProvider {
    static var previews: some View {
        HapticFeedbackButton(
            action: { print("clicked") },
            label: { Image(systemName: "square.and.arrow.up") }
        )
        .previewLayout(.sizeThatFits)
        .environment(\.locale, .init(identifier: "uk"))
    }
}
