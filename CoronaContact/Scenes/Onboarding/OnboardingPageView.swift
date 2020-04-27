//
//  OnboardingPageView.swift
//  CoronaContact
//

import UIKit
import Reusable
import Resolver
import SwiftRichString

final class OnboardingPageView: UIView, NibLoadable {
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var textLabel2: UILabel!
    @IBOutlet weak var button: TransButton!
    @IBOutlet weak var imageView: UIImageView!

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
