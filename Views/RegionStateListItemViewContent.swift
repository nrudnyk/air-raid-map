//
//  RegionStateListItemViewContent.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 07.07.2022.
//

import SwiftUI

struct RegionStateListItemViewContent: View {
    @Environment(\.sizeCategory) var sizeCategory
    private let name: String
    private let state: AlertState

    init(name: String, state: AlertState) {
        self.name = name
        self.state = state
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text(LocalizedStringKey(name))
                    .font(.headline)
                    .bold()
                    .lineLimit(1)

                Spacer()
            }

            HStack(spacing: 0) {
                Image(systemName: "clock.arrow.circlepath")
                Text(" ")
                if sizeCategory <= .accessibilityExtraLarge {
                    switch state.type {
                    case .airAlarm: Text("last").italic()
                    case .allClear: Text("silence").italic()
                    default: EmptyView()
                    }
                }
                Text(" ")
                Text(state.changedAt, style: .relative).italic()
            }
            .font(.footnote)
            .foregroundColor(state.type.color)

            if state.type == .airAlarm {
                HStack(spacing: 0) {
                    Image(systemName: "megaphone")
                    Text(" ")
                    if sizeCategory <= .accessibilityExtraLarge {
                        Text("announced")
                    }
                    Text(" ")
                    Text(DateFormatter.timePreposition(for: state.changedAt))
                    Text(" ")
                    Text(state.changedAt, style: .time)
                }
                .font(.footnote)
                .foregroundColor(.orange)
            }
        }
    }
}

struct RegionStateListItemViewContent_Previews: PreviewProvider {
    static var previews: some View {
        RegionStateListItemViewContent(
            name: "Ivano-Frankivsk oblast",
            state: AlertState(type: .airAlarm, changedAt: Date().addingTimeInterval(-80000))
        )
        .environment(\.sizeCategory, .accessibilityExtraLarge)
        .previewLayout(.sizeThatFits)
        .environment(\.locale, .init(identifier: "uk"))
    }
}
