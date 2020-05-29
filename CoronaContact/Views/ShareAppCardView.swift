//
//  ShareAppCardView.swift
//  CoronaContact
//

import Reusable
import UIKit

class ShareAppCardView: UIView, NibOwnerLoadable {
    @IBOutlet var innerView: UIView!
    @IBOutlet var headlineLabel: UILabel!
    @IBOutlet var descriptionLabel: TransLabel!
    @IBOutlet var shareButton: ArrowButton!

    var handlePrimaryTap: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        loadNibContent()
        configureView()
    }

    private func configureView() {
        innerView.layer.cornerRadius = 10
        innerView.addStandardShadow()

        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedView))
        innerView.isUserInteractionEnabled = true
        innerView.addGestureRecognizer(tap)

        let textColor = UIColor.white
        headlineLabel.textColor = textColor
        descriptionLabel.textColor = textColor
        shareButton.configureAppearance(textColor: textColor, arrowColor: textColor)
    }

    @objc
    private func tappedView() {
        handlePrimaryTap?()
    }
}
