//
//  UIView+embedSubview.swift
//  CoronaContact
//

import UIKit

extension UIView {
    func embedSubview(_ subview: UIView) {
        if subview.superview == self { return }

        if subview.superview != nil {
            subview.removeFromSuperview()
        }

        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)

        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: leadingAnchor),
            trailingAnchor.constraint(equalTo: subview.trailingAnchor),
            subview.topAnchor.constraint(equalTo: topAnchor),
            bottomAnchor.constraint(equalTo: subview.bottomAnchor)
        ])
    }
}
