//
//  EffectView.swift
//  air-raid-map (iOS)
//
//  Created by Nazar Rudnyk on 18.05.2022.
//

import SwiftUI

internal struct EffectView: UIViewRepresentable {
    var effect: UIVisualEffect
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: self.effect)
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = self.effect
    }
}

struct EffectView_Previews: PreviewProvider {
    static var previews: some View {
        EffectView(effect: UIBlurEffect(style: .regular))
    }
}

