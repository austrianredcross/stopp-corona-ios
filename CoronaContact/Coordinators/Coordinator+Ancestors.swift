//
//  Coordinator+Ancestors.swift
//  CoronaContact
//

import Foundation

extension Coordinator {

    ///
    /// A sequence containing all ancestors by traversing the `parentCoordinator` hierarchy
    ///
    /// Includes `self` as the first element.
    ///
    var ancestors: AnySequence<Coordinator> {
        AnySequence(sequence(first: self) { $0.parentCoordinator })
    }
}
