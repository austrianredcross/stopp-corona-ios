//
//  UIView+Shadow.swift
//  CoronaContact
//

import UIKit

extension UIView {
    /// SwifterSwift: Add shadow to view.
    ///
    /// - Parameters:
    ///   - color: shadow color (default is #137992).
    ///   - radius: shadow radius (default is 3).
    ///   - offset: shadow offset (default is .zero).
    ///   - opacity: shadow opacity (default is 0.5).
    func addShadow(ofColor color: UIColor = UIColor(red: 0.07, green: 0.47, blue: 0.57, alpha: 1.0),
                   radius: CGFloat = 3, offset: CGSize = .zero, opacity: Float = 0.5)
    {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.masksToBounds = false
    }

    func addStandardShadow() {
        addShadow(
            ofColor: UIColor.ccBlack,
            radius: 8,
            offset: CGSize(width: 2, height: 2),
            opacity: 0.23
        )
    }
}
