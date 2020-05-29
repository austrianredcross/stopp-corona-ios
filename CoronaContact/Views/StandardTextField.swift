//
//  StandardTextField.swift
//  CoronaContact
//

import UIKit

class StandardTextField: FloatingTextField {
    override func configureView() {
        super.configureView()

        let smallFont = UIFont.systemFont(ofSize: 15)
        let regularFont = UIFont.systemFont(ofSize: 18)
        insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        labelInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        font = regularFont
        labelFont = smallFont
        placeholderFont = regularFont
        errorFont = smallFont
    }
}
