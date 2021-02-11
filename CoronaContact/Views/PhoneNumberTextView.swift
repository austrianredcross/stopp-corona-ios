//
//  PhoneNumberTextView.swift
//  CoronaContact
//

import Foundation

class PhoneNumberTextView: LinkTextView {
    @IBInspectable var transKey: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if let transKey = transKey {
            self.textViewAttribute = TextViewAttribute(fullText: transKey.localized, links: [ DeepLinkConstants.deepLinkPhoneNumber], linkColor: .ccRouge)
        }
    }
}
