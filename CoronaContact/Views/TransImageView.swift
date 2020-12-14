//
//  TransImageView.swift
//  CoronaContact
//

import UIKit


class TransImageView: UIImageView {
    @IBInspectable var transKey: String? { didSet { updateAccessibility() } }

    override func awakeFromNib() {
        super.awakeFromNib()
        updateAccessibility()
    }
    
    private func updateAccessibility() {
        if let transKey = transKey {
            self.isAccessibilityElement = true
            self.accessibilityLabel = transKey.localized
        }
    }
}
