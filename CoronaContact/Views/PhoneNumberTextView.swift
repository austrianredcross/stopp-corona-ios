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
            
            let ranges = transKey.localized.ranges(regex: "</?[a-z]+>")
            var links = [String]()
                                    
            for index in 0..<ranges.count / 2 {
                if transKey.localized[ranges[(index * 2)]].contains("<tel>") {
                    links.append(DeepLinkConstants.deepLinkPhoneNumber)
                } else {
                    links.append(DeepLinkConstants.emptyLink)
                }
            }
                        
            self.textViewAttribute = TextViewAttribute(fullText: transKey.localized, links: links, linkColor: .ccLink)
        }
    }
}
