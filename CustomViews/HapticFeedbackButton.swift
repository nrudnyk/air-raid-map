//
//  HapticFeedbackButton.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 16.05.2022.
//

import SwiftUI

struct HapticFeedbackButton<Label: View>: View {
#if os(iOS)
    private let defaultPadding = 12.0
#else
    private let defaultPadding = 0.0
#endif
    
#if os(iOS)
    private let hapticFeedbacGenerator = UINotificationFeedbackGenerator()
    
    let feedbackType: UINotificationFeedbackGenerator.FeedbackType
#endif
    let action: () -> Void
    let label: () -> Label
    
#if os(iOS)
    init(
        action: @escaping () -> Void,
        label: @escaping () -> Label,
        feedbackType: UINotificationFeedbackGenerator.FeedbackType = .success
    ) {
        self.feedbackType = feedbackType
        self.action = action
        self.label = label
    }
#else
    init(action: @escaping () -> Void, label: @escaping () -> Label) {
        self.action = action
        self.label = label
    }
#endif
    
    var body: some View {
        buttonView.padding(defaultPadding)
    }
    
    fileprivate var buttonView: some View {
        Button(
            action: {
#if os(iOS)
                hapticFeedbacGenerator.notificationOccurred(feedbackType)
#endif
                action()
            },
            label: label
        )
    }
}
