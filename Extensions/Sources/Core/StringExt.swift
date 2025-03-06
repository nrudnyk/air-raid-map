//
//  File.swift
//  
//
//  Created by Nazar Rudnyk on 19.07.2022.
//

import Foundation

public extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
