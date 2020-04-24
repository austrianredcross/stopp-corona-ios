//
//  ArrowButton.swift
//  CoronaContact
//

import UIKit
import SwiftRichString

class ArrowButton: TransButton {

    @IBInspectable private var arrowImage: UIImage? = UIImage(named: "ArrowRight") {
        didSet {
            configureButton()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    @IBInspectable var spacing: CGFloat = 8 {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureButton()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        configureButton()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        configureButton()
    }

    func configureButton() {
        titleEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: spacing)
        setImage(arrowImage, for: .normal)
    }

    func configureAppearance(textColor: UIColor, arrowColor: UIColor) {
        self.textColor = textColor
        let tintedImage = arrowImage?.withRenderingMode(.alwaysTemplate)
        imageView?.tintColor = arrowColor
        imageView?.contentMode = .scaleAspectFit
        setImage(tintedImage, for: .normal)
        setImage(tintedImage, for: .disabled)
        setImage(tintedImage, for: .highlighted)
    }

    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        var imageFrame = super.imageRect(forContentRect: contentRect)
        imageFrame.origin.x = contentRect.maxX - imageFrame.width
        return imageFrame
    }

    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        var titleFrame = super.titleRect(forContentRect: contentRect)
        let imageFrame = super.imageRect(forContentRect: contentRect)
        if currentImage != nil {
            titleFrame.origin.x = imageFrame.minX
        }
        return titleFrame
    }
}
