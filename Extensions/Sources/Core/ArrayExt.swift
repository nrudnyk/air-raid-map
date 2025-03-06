//
//  Extensions.swift
//  air-raid-map (iOS)
//
//  Created by Nazar Rudnyk on 20.04.2022.
//

import Foundation

public extension Array {
    func toDictionary<Key: Hashable>(_ selectKey: (Element) -> Key) -> [Key: Element] {
        var result = [Key: Element]()
        for element in self {
            result[selectKey(element)] = element
        }
        
        return result
    }
}
