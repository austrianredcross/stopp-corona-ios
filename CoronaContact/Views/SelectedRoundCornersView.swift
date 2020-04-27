//
//  SelectedRoundCornersView.swift
//  CoronaContact
//

import UIKit

class SelectedRoundCornersView: UIView {
    var corners: UIRectCorner?
    var radius: CGFloat?

    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        self.corners = corners
        self.radius = radius

        updateLayer()
    }

    func updateLayer() {
        if let corners = corners, let radius = radius {
            let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayer()
    }
}
