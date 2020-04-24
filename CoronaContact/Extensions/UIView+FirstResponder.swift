//
//  UIView+FirstResponder.swift
//  CoronaContact
//

import UIKit

extension UIView {
    /**
     Find the current first responder in the receiver's descendants

     Recursively inspects the subview hierarchy (depth-first) until the
     firstResponder is found.
     */
    var firstResponder: UIView? {
        guard !isFirstResponder else { return self }

        for subview in subviews {
            if let firstResponder = subview.firstResponder {
                return firstResponder
            }
        }

        return nil
    }
}
