//
//  LinkTextView.swift
//  CoronaContact
//

import UIKit

struct TextViewAttribute {
    let fullText: String
    let links: [String]
    let linkColor: UIColor
}

class LinkTextView: UITextView, UITextViewDelegate {
    
    var textViewAttribute: TextViewAttribute? {
        didSet {
            configureTextView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func configureTextView() {
        
        guard let attributes = textViewAttribute else { return }
        
        delegate = self
        isEditable = false
        isScrollEnabled = false
        backgroundColor = .clear
        
        guard let styledFullText = attributes.fullText.locaStyled(style: .body) else {
            text = attributes.fullText
            return
        }
        
        let ranges = attributes.fullText.ranges(regex: "</?[a-z]+>")
        
        guard ranges.count == (attributes.links.count * 2) else {
            attributedText = styledFullText
            return
        }
        
        var removesTagsCharacterCount = 0
        let mutableAttributesString = NSMutableAttributedString(attributedString: styledFullText)
        
        for (index, link) in attributes.links.enumerated() {
            
            let linkStartTagLowerBound = ranges[(index * 2)].lowerBound.utf16Offset(in: attributes.fullText)
            let linkStartTagUpperBound = ranges[(index * 2)].upperBound.utf16Offset(in: attributes.fullText)
            let linkEndTagLowerBound = ranges[(index * 2) + 1].lowerBound.utf16Offset(in: attributes.fullText)
            let linkEndTagUpperBound = ranges[(index * 2) + 1].upperBound.utf16Offset(in: attributes.fullText)
            
            let linkLength = linkEndTagLowerBound - linkStartTagUpperBound
            let startLocation = index == 0 ? linkStartTagLowerBound : (linkStartTagLowerBound - removesTagsCharacterCount)
            let attributeRange = NSRange(location: startLocation, length: linkLength)
            
            if link.contains(DeepLinkConstants.deepLinkPhoneNumber) {
                let phoneNumber = link + styledFullText.attributedSubstring(from: attributeRange).string.replacingOccurrences(of: " ", with: "")
                mutableAttributesString.addAttribute(.link, value: phoneNumber, range: attributeRange)
            } else if !link.isEmpty {
                mutableAttributesString.addAttribute(.link, value: link, range: attributeRange)
            }

            linkTextAttributes = [NSAttributedString.Key.foregroundColor: attributes.linkColor]
            removesTagsCharacterCount += (linkStartTagUpperBound - linkStartTagLowerBound) + (linkEndTagUpperBound - linkEndTagLowerBound)
        }
        
        attributedText = mutableAttributesString
    }
    
    func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if url.absoluteString.contains(DeepLinkConstants.deepLinkPhoneNumber) {
            callNumber(with: url)
            return false
        }
        return true
    }
    
    func callNumber(with phoneCallURL: URL) {
        if UIApplication.shared.canOpenURL(phoneCallURL) {
            UIApplication.shared.open(phoneCallURL, options: [:], completionHandler: nil)
        }
    }
}
