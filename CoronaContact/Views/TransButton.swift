//
//  TransButton.swift
//  CoronaContact
//

import SwiftRichString
import UIKit

// @IBDesignable
class TransButton: UIButton {
    @IBInspectable var normalStyle: String?
    @IBInspectable var transKeyNormal: String? { didSet { updateTranslation() } }
    @IBInspectable var multiline: Bool = false

    var textColor: UIColor? { didSet { updateTexts() } }

    var styledTextNormal: String = "" { didSet { updateTexts() } }

    private func updateTexts() {
        if let normalStyle = normalStyle {
            var text = styledTextNormal.set(style: normalStyle)
            if !multiline {
                text = text?.add(style: ModifierNames.truncatingMiddle.rawValue)
            }

            if let textColor = textColor {
                let textColorStyle = Style {
                    $0.color = textColor
                }

                text?.add(style: textColorStyle)
            }

            setAttributedTitle(text, for: .normal)
        } else {
            setTitle(styledTextNormal, for: .normal)
        }
    }

    func updateTranslation() {
        if let transKeyNormal = transKeyNormal { styledTextNormal = transKeyNormal.localized }
        updateTexts()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        if multiline {
            titleLabel?.numberOfLines = 0
            setContentHuggingPriority(.defaultLow, for: .vertical)
            if let titleHeightAnchor = titleLabel?.heightAnchor {
                let heightConstraint = heightAnchor.constraint(equalTo: titleHeightAnchor)
                heightConstraint.priority = .defaultHigh
                heightConstraint.isActive = true
            }
        }
        updateTranslation()
    }
}
