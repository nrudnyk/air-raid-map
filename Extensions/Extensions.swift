//
//  Extensions.swift
//  air-raid-map (iOS)
//
//  Created by Nazar Rudnyk on 20.04.2022.
//

import MapKit

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
    
    static let shortDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm, dd MMM"
        formatter.locale = Locale.current
        
        return formatter
    }()
    
    static func timePreposition(for date: Date) -> String {
        let langCode = Locale.current.languageCode
        switch langCode {
        case "uk":
            let hour = Calendar.current.component(.hour, from: date)
            let preposition = hour == 11 ? "об" : "о"
            return preposition
        case "en":
            return "at"
        default:
            return ""
        }
    }
}
