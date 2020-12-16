//
//  OnboardingPageView.swift
//  CoronaContact
//

import Resolver
import Reusable
import SwiftRichString
import UIKit

final class OnboardingPageView: UIView, NibLoadable {
    @IBOutlet var headingLabel: TransHeadingLabel!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var textLabel2: UILabel!
    @IBOutlet var textView: LinkTextView!
    @IBOutlet var imageView: TransImageView!
    @IBOutlet var button: TransButton!

    var page: OnboardingPage? {
        didSet {
            guard let page = page else {
                return
            }

            headingLabel.styledText = page.headline
            textLabel.attributedText = page.text.locaStyled(style: .body)

            if let text2 = page.text2 {
                textLabel2.styledText = text2
                textLabel2.isHidden = false
            }
            
            if let textViewText = page.textViewText {
                textView.textViewAttribute = TextViewAttribute(fullText: textViewText, links: [DeepLinkConstants.deepLinkTermsOfUseUrl, DeepLinkConstants.deepLinkFAQUrl], linkColor: UIColor.ccRouge)
            } else {
                textView.isHidden = true
            }
            
            if let buttonText = page.buttonText {
                button.styledTextNormal = buttonText
            } else {
                button.isHidden = true
            }
            
            if let buttonIcon = page.buttonIcon, let image = UIImage(named: buttonIcon) {
                button.setImage(image, for: .normal)
            }

            if let pageImage = page.image, let image = UIImage(named: pageImage) {
                imageView.transKey = page.imageAccessibiltyText
                imageView.image = image
            } else {
                imageView.isHidden = true
            }
        }
    }

    @IBAction func buttonTapped() {
        page?.buttonHandler?()
    }
}
