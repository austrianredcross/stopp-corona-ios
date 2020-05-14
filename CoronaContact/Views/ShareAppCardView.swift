//
//  ShareAppCardView.swift
//  CoronaContact
//

import UIKit
import Reusable

class ShareAppCardView: UIView, NibOwnerLoadable {

    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var descriptionLabel: TransLabel!
    @IBOutlet weak var shareButton: ArrowButton!

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
