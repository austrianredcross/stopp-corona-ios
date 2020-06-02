//
//  UIResponder+Traversing.swift
//  CoronaContact
//

import UIKit

extension UIResponder {
    /**
     Find the first responder of the given type in the chain

     - parameters:
       - type: The type of responder to look for
       - view: Stop searching when `view` is encountered. If `nil`, the responder chain may be traversed to the end.
     */
    func first<T: UIResponder>(ofType type: T.Type, stopAt view: UIView?) -> T? {
        first(stopAt: view, matching: { $0 is T }) as? T
    }

    private func first(stopAt view: UIView?, matching predicate: (UIResponder) -> Bool) -> UIResponder? {
        if predicate(self) {
            return self
        }
        if let view = view, self === view {
            return nil
        }
        return next?.first(stopAt: view, matching: predicate)
    }
}
