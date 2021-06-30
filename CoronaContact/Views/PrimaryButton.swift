//
//  PrimaryButton.swift
//  CoronaContact
//

import UIKit

class PrimaryButton: TransButton {
    override func updateTranslation() {
        if let transKeyNormal = transKeyNormal {
            setAttributedTitle(transKeyNormal.locaStyled(style: .primaryButton), for: .normal)
        }
    }

    override public var isEnabled: Bool {
        didSet {
            if self.isEnabled {
                backgroundColor = .ccRedButton
            } else {
                backgroundColor = .ccBrownGrey
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        if isEnabled { backgroundColor = .ccRedButton } else { backgroundColor = .ccBrownGrey }
        layer.cornerRadius = 8
        layer.masksToBounds = true
        heightAnchor.constraint(equalToConstant: defaultHeightConstant).isActive = true
    }
}
