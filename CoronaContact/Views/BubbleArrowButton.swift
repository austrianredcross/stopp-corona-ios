//
//  BubbleArrowButton.swift
//  CoronaContact
//

import UIKit

class BubbleArrowButton: ArrowButton {

    override func configureButton() {
        super.configureButton()

        titleEdgeInsets = .zero
        configureAppearance(textColor: .ccWhite, arrowColor: .ccWhite)
        layer.cornerRadius = 8
    }

    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        var imageFrame = super.imageRect(forContentRect: contentRect)
        imageFrame.origin.x = contentRect.maxX - imageFrame.width
        imageFrame.origin.x = contentRect.maxX - imageFrame.width + spacing
        return imageFrame
    }
}
