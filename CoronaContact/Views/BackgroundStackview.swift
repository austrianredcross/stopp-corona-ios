//
//  BackgroundStackview.swift
//  CoronaContact
//

import UIKit

class BackgroundStackView: UIStackView {
    private var overridenMargin: CGFloat = 0 {
        didSet { layoutMarginsDidChange() }
    }

    @IBInspectable var stackBackgroundColor: UIColor?

    @IBInspectable var overrideVertMarginMulti: CGFloat = 0 {
        didSet {
            isLayoutMarginsRelativeArrangement = true
            layoutMarginsDidChange()
        }
    }

    @IBInspectable var overrideHorztMarginMulti: CGFloat = 0 {
        didSet {
            isLayoutMarginsRelativeArrangement = true
            layoutMarginsDidChange()
        }
    }

    @IBInspectable var overrideSpacingMulti: CGFloat = 0 {
        didSet {
            if overrideSpacingMulti > 0 {
                spacing = overridenMargin * overrideSpacingMulti
                layoutSubviews()
            }
        }
    }

    override var isLayoutMarginsRelativeArrangement: Bool {
        get {
            if overrideHorztMarginMulti > 0 || overrideVertMarginMulti > 0 { return true }
            return super.isLayoutMarginsRelativeArrangement
        }
        set(newValue) {
            super.isLayoutMarginsRelativeArrangement = newValue
        }
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            switch appDelegate.screenSize {
            case .small:
                overridenMargin = 16
            case .medium:
                overridenMargin = 16
            case .large:
                overridenMargin = 24
            }
        }
    }

    override var layoutMargins: UIEdgeInsets {
        get {
            let margins = super.layoutMargins
            let newMargins = UIEdgeInsets(top: overrideVertMarginMulti > 0 ? overridenMargin * overrideVertMarginMulti : margins.top,
                                          left: overrideHorztMarginMulti > 0 ? overridenMargin * overrideHorztMarginMulti : margins.left,
                                          bottom: overrideVertMarginMulti > 0 ? overridenMargin * overrideVertMarginMulti : margins.bottom,
                                          right: overrideHorztMarginMulti > 0 ? overridenMargin * overrideHorztMarginMulti : margins.right)
            return newMargins
        }
        set(newValue) {
            super.layoutMargins = newValue
        }
    }

    func addBackground(color: UIColor) {
        let subview = UIView(frame: bounds)
        subview.backgroundColor = color
        subview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subview, at: 0)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        if let backgroundColor = stackBackgroundColor, backgroundColor != UIColor.clear {
            addBackground(color: backgroundColor)
        }
    }
}
