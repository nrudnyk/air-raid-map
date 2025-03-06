//
//  HapticFeedbackExtension.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 27.04.2022.
//

import SwiftUI

func selectionHapticFeedback() {
#if os(iOS)
    let selection = UISelectionFeedbackGenerator()
    selection.selectionChanged()
#endif
}
