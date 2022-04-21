//
//  Extensions.swift
//  air-raid-map (iOS)
//
//  Created by Nazar Rudnyk on 20.04.2022.
//

import MapKit

extension CLLocationCoordinate2D {
    static let centerOfUkraine = CLLocationCoordinate2DMake(48.383022, 31.1828699)
}

extension Array {
    public func toDictionary<Key: Hashable>(_ selectKey: (Element) -> Key) -> [Key: Element] {
        var result = [Key: Element]()
        for element in self {
            result[selectKey(element)] = element
        }
        
        return result
    }
}

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        return formatter
    }()
    
    static let iso8601UTC: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSSZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        return formatter
    }()
}
