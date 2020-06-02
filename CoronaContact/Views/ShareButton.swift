//
//  ShareButton.swift
//  CoronaContact
//

import Foundation
import UIKit

class ShareButton: ArrowButton {
    var leftImageSize: CGFloat = 24

    lazy var leftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ShareIcon")
        imageView.setContentHuggingPriority(.required, for: .vertical)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    override func configureButton() {
        super.configureButton()

        spacing = 12
        layer.cornerRadius = 8
        backgroundColor = .ccBlue
        contentHorizontalAlignment = .leading
        addStandardShadow()
        configureAppearance(textColor: .white, arrowColor: .white)

        addSubview(leftImageView)

        NSLayoutConstraint.activate([
            leftImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: spacing),
            leftImageView.widthAnchor.constraint(equalToConstant: leftImageSize),
            leftImageView.heightAnchor.constraint(equalTo: leftImageView.widthAnchor),
            leftImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        var titleFrame = super.titleRect(forContentRect: contentRect)
        let leftImageFrame = leftImageView.frame
        let rightImageFrame = super.imageRect(forContentRect: contentRect)
        if currentImage != nil {
            titleFrame.origin.x = leftImageFrame.maxX + spacing
            titleFrame.size.width =
                contentRect.width -
                (leftImageFrame.width + (2 * spacing)) -
                (rightImageFrame.width + (2 * spacing))
        }
        return titleFrame
    }

    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        var imageFrame = super.imageRect(forContentRect: contentRect)
        imageFrame.origin.x = contentRect.maxX - imageFrame.width - spacing
        return imageFrame
    }
}
