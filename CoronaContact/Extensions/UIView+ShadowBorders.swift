//
//  UIView+ShadowBorders.swift
//  CoronaContact
//

import UIKit

// @IBDesignable
extension UIView {
    @IBInspectable var borderColor: UIColor? {
        get {
            guard let color = layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: color)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }

    @IBInspectable private var borderWidth: CGFloat {
        get {
            layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable private var cornerRadius: CGFloat {
        get {
            layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }

    @IBInspectable private var shadowColor: UIColor? {
        get {
            guard let color = layer.shadowColor else {
                return nil
            }
            return UIColor(cgColor: color)
        }
        set {
            layer.shadowColor = newValue?.cgColor
        }
    }

    @IBInspectable private var setShadowOpacity: Float {
        get {
            layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }

    @IBInspectable private var setShadowRadius: CGFloat {
        get {
            layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }

    @IBInspectable private var setShadowOffset: CGSize {
        get {
            layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
}
