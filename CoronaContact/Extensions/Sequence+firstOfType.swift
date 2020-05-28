//
//  Sequence+firstOfType.swift
//  CoronaContact
//

import Foundation

public extension Sequence {

    /// Returns the first element of the given type
    ///
    /// - parameters:
    ///   - type: The type of the element to be found
    ///
    /// - returns: The first element of the given type if available, else `nil`
    ///
    func firstOfType<T>(_ type: T.Type) -> T? {
        guard let found = first(where: { $0 is T }) as? T else {
            return nil
        }
        return found
    }
}
