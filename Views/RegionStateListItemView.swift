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
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text(regionState.name)
                    .font(.headline)
                    .bold()
                Spacer()
            }
            
            HStack(spacing: 0) {
                Image(systemName: "clock.arrow.circlepath")
                Text(" триває ").italic()
                Text(regionState.alertState.changedAt, style: .relative).italic()
            }
            .font(.footnote)
            .foregroundColor(.red)
            
            HStack(spacing: 0) {
                Image(systemName: "megaphone")
                Text(" оголошено \(DateFormatter.shortString(from: regionState.alertState.changedAt))").italic()
            }
            .font(.footnote)
            .foregroundColor(.yellow)
        }
    }
}

struct RegionStateListItemView_Previews: PreviewProvider {
    static var previews: some View {
        RegionStateListItemView(regionState: RegionStateModel(
            id_0: 0,
            name: "Київська Область",
            geometry: MKPolygon(),
            alertState: AlertState()
        ))
        .previewLayout(.sizeThatFits)
    }
}
