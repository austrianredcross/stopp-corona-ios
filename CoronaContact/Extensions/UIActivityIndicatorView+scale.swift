//
//  UIActivityIndicatorView+scale.swift
//  CoronaContact
//

import UIKit

extension UIActivityIndicatorView {
    func scale(factor: CGFloat) {
        guard factor > 0.0 else { return }

        transform = CGAffineTransform(scaleX: factor, y: factor)
    }
}
