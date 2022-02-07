//
//  SunDownerPageView.swift
//  CoronaContact
//

import Resolver
import Reusable
import SwiftRichString
import UIKit

final class SunDownerPageView: UIView, NibLoadable {
    @IBOutlet var headingLabel: TransHeadingLabel!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var imageView: TransImageView!
    @IBOutlet var newsletterButton: SecondaryButton!
    
    var newsletterCallback: (() -> Void)?
    
    var page: SunDownerPage? {
        didSet {
            guard let page = page else {
                return
            }
            
            headingLabel.styledText = page.headline
           
            textLabel.attributedText = page.text.locaStyled(style: .body)
            
            if let buttonText = page.buttonText {
                newsletterButton.transKeyNormal = buttonText
                newsletterButton.accessibilityHint = "sunDowner_newsletter_link_accessibility".localized
                newsletterButton.updateTranslation()
            } else {
                newsletterButton.isHidden = true
            }
            
            if let pageImage = page.image, let image = UIImage(named: pageImage) {
                imageView.transKey = page.imageAccessibiltyText
                imageView.image = image
            } else {
                imageView.isHidden = true
            }
        }
    }
    
    @IBAction func newsletterButtonPressed(_ sender: Any) {
        newsletterCallback?()
    }
}
