//
//  NSManagedObjectContextExtensions.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 29.06.2022.
//

import Foundation
import CoreData

public extension NSManagedObjectContext {
    func performBlock(_ block: @escaping () throws -> Void) async throws {
        if #available(macOS 12.0, iOS 15.0, *) {
            try await perform(block)
        } else {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) -> Void in
                self.perform {
                    do {
                        try block()
                        continuation.resume()
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
}
