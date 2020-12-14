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
    @IBOutlet var button: TransButton!
    @IBOutlet var imageView: UIImageView!

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

            if let buttonText = page.buttonText {
                button.styledTextNormal = buttonText
            } else {
                button.isHidden = true
            }

            if let pageImage = page.image, let image = UIImage(named: pageImage) {
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
