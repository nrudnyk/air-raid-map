//
//  HapticFeedbackButton.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 16.05.2022.
//

import SwiftUI

struct HapticFeedbackButton<Label: View>: View {
    private let hapticFeedbacGenerator = UINotificationFeedbackGenerator()
    
    let feedbackType: UINotificationFeedbackGenerator.FeedbackType
    let action: () -> Void
    let label: () -> Label
    
    init(
        feedbackType: UINotificationFeedbackGenerator.FeedbackType = .success,
        action: @escaping () -> Void,
        label: @escaping () -> Label
    ) {
        self.feedbackType = feedbackType
        self.action = action
        self.label = label
    }
    
    var body: some View {
        Button(
            action: {
                hapticFeedbacGenerator.notificationOccurred(feedbackType)
                action()
            },
            label: label
        )
    }
}
