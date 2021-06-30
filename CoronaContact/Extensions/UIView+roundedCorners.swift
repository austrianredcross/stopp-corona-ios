//
//  UIView+roundedCorners.swift
//  CoronaContact
//

import UIKit

extension UIView {
    enum CornerRadiusSize: CGFloat {
        case small = 5.0
        case normal = 10.0
    }
    
    func roundedCorners(corners: CACornerMask, radius: CornerRadiusSize) {
        clipsToBounds = true
        layer.cornerRadius = radius.rawValue
        layer.maskedCorners = corners
    }
}
