//
//  TransImageView.swift
//  CoronaContact
//

import UIKit


class TransImageView: UIImageView {
    @IBInspectable var transKey: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        if let transKey = transKey {
            self.isAccessibilityElement = true
            self.accessibilityLabel = transKey.localized
        }
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        if let transKey = transKey {
            self.isAccessibilityElement = true
            self.accessibilityLabel = transKey.localized
        }
    }
}
