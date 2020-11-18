//
//  TransBarButton.swift
//  CoronaContact
//

import SwiftRichString
import UIKit

// @IBDesignable
class TransBarButton: UIBarButtonItem {
    @IBInspectable var transKeyNormal: String? { didSet { updateTranslation() } }

    func updateTranslation() {
        if let transKeyNormal = transKeyNormal { self.accessibilityLabel = transKeyNormal.localized }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        updateTranslation()
    }
}
