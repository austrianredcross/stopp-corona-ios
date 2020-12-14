//  TransHeadingLabel.swift
//  CoronaContact
//

import Resolver
import SwiftRichString
import UIKit

// SLOW @IBDesignable
class TransHeadingLabel: UILabel {
    @IBInspectable var transKey: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        if let transKey = transKey {
            styledText = transKey.localized
        }
        
        accessibilityHint = "accessibility_heading_1".localized
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        if let transKey = transKey {
            text = transKey
        }
    }
}
