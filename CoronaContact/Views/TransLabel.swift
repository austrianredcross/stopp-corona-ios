//
//  TransLabel.swift
//  CoronaContact
//

import Resolver
import SwiftRichString
import UIKit

// SLOW @IBDesignable
class TransLabel: UILabel {
    @IBInspectable var transKey: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        if let transKey = transKey {
            styledText = transKey.localized
        }
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        if let transKey = transKey {
            text = transKey
        }
    }
}
