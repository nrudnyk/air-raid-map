//
//  ShareSheet.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 07.07.2022.
//

import SwiftUI

struct ShareActivityView: UIViewControllerRepresentable {
    typealias Callback = (
        _ activityType: UIActivity.ActivityType?,
        _ completed: Bool,
        _ returnedItems: [Any]?,
        _ error: Error?
    ) -> Void

    private let feedbackGenerator = UINotificationFeedbackGenerator()

    let activityItems: [Any]
    let applicationActivities: [UIActivity]?
    let excludedActivityTypes: [UIActivity.ActivityType]?
    let callback: Callback?

    init(
        activityItems: [Any],
        applicationActivities: [UIActivity]? = nil,
        excludedActivityTypes: [UIActivity.ActivityType]? = nil,
        callback: Callback? = nil
    ) {
        self.activityItems = activityItems
        self.applicationActivities = applicationActivities
        self.excludedActivityTypes = excludedActivityTypes
        self.callback = callback
    }

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityController = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        activityController.excludedActivityTypes = excludedActivityTypes
        activityController.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            feedbackGenerator.notificationOccurred(.success)
            callback?(activityType, completed, returnedItems, error)
        }
        activityController.completionWithItemsHandler = callback

        return activityController
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // nothing to do here
    }
}
