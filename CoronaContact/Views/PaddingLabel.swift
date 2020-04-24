//
//  PaddingLabel.swift
//  CoronaContact
//

import UIKit

class PaddingLabel: UILabel {

    var insets: UIEdgeInsets = .zero

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += insets.top + insets.bottom
        contentSize.width += insets.left + insets.right
        return contentSize
    }
}
