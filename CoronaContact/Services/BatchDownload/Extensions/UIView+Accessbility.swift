//
//  UIView+Accessbility.swift
//  CoronaContact
//

import UIKit

extension UIView {
    
    func setAccessibilityLabel(with elements: [String]) {
        // Voice over will make a short break when reading ","
        self.accessibilityLabel = elements.joined(separator: ",")
    }

    func setAccessibilityElements(with elements: [UIView]) {
        self.accessibilityElements = elements
    }
}
