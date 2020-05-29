//
//  UIView+roundedCorners.swift
//  CoronaContact
//

import UIKit

extension UIView {
    func roundedCorners(corners: CACornerMask, radius: CGFloat) {
        clipsToBounds = true
        layer.cornerRadius = radius
        layer.maskedCorners = corners
    }
}
