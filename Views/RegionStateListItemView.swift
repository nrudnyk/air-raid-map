//
//  RegionStateListItemView.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 23.04.2022.
//

import SwiftUI
import MapKit

struct RegionStateListItemView: View {
    let regionState: RegionStateModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    Text(regionState.name)
                        .font(.title3)
                        .bold()
                        
                    Spacer()
                    HStack {
                        Text(DateFormatter.shortDateTime.string(from: regionState.alertState.changedAt))
                    }.font(.subheadline)
                }
                HStack {
                    Text("⚠️Триває").italic()
                    Text(regionState.alertState.changedAt, style: .relative).italic()
                }.foregroundColor(.red)
            }
        }
    }
}

struct RegionStateListItemView_Previews: PreviewProvider {
    static var previews: some View {
        RegionStateListItemView(regionState: RegionStateModel(
            id: 0,
            name: "Київська Область",
            geometry: MKPolygon(),
            alertState: AlertState()
        ))
        .previewLayout(.sizeThatFits)
    }
}
