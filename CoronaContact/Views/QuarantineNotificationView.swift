//
//  QuarantineNotificationView.swift
//  CoronaContact
//

import UIKit
import Reusable

struct ButtonAction {

    let title: String
    let handler: () -> Void

    init(title: String, handler: @escaping () -> Void) {
        self.title = title
        self.handler = handler
    }
}

enum QuarantineNotificationAppearance {
    case regular
    case color

    var textColor: UIColor {
        switch self {
        case .regular:
            return .ccBlack
        case .color:
            return .ccWhite
        }
    }

    var closeButtonColor: UIColor {
        switch self {
        case .regular:
            return .ccBlack
        case .color:
            return .ccWhite
        }
    }

    var arrowButtonColor: UIColor {
        switch self {
        case .regular:
            return .ccRouge
        case .color:
            return .ccWhite
        }
    }
}

extension RevocationStatus {
    var notificationAppearance: QuarantineNotificationAppearance {
        .color
    }
}

class QuarantineNotificationView: UIView, NibOwnerLoadable {

    @IBInspectable var indicatorColor: UIColor? {
        didSet {
            if let indicatorColor = indicatorColor {
                innerView.backgroundColor = indicatorColor
            }
        }
    }
    @IBInspectable var icon: UIImage? {
        didSet {
            if let icon = icon {
                iconImageView.image = icon.withRenderingMode(.alwaysTemplate)
                iconImageView.tintColor = .white
                iconImageView.isHidden = false
            } else {
                iconImageView.isHidden = true
            }
        }
    }
    @IBInspectable var headlineText: String = "" {
        didSet {
            headlineLabel.text = headlineText
        }
    }
    @IBInspectable var descriptionText: String = "" {
        didSet {
            descriptionLabel.styledText = descriptionText
            descriptionLabel.textColor = appearance.textColor
        }
    }
    @IBInspectable var buttonText: String = "" {
        didSet {
            primaryButton.styledTextNormal = buttonText
        }
    }
    @IBInspectable var isPrimaryButtonEnabed: Bool = true {
        didSet {
            primaryButtonContainerView.isHidden = !isPrimaryButtonEnabed
        }
    }
    var quarantineCounter: Int? {
        didSet {
            if let quarantineCounter = quarantineCounter {
                quarantineCounterLabel.text = "\(quarantineCounter)"
                quarantineCounterLabel.isHidden = false
            } else {
                quarantineCounterLabel.isHidden = true
            }
        }
    }
    var appearance: QuarantineNotificationAppearance = .color {
        didSet {
            configureAppearance()
        }
    }

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton! {
        didSet {
            closeButton.isHidden = true
        }
    }
    @IBOutlet weak var descriptionLabel: TransLabel!
    @IBOutlet weak var primaryButtonContainerView: UIView!
    @IBOutlet weak var quarantineCounterLabel: PaddingLabel! {
        didSet {
            quarantineCounterLabel.isHidden = true
        }
    }
    @IBOutlet weak var primaryButton: ArrowButton!
    @IBOutlet weak var buttonsStackView: UIStackView!

    var handlePrimaryTap: (() -> Void)?
    var handleClose: (() -> Void)?
    var buttonActions = [ButtonAction]()

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

        primaryButtonContainerView.isHidden = !isPrimaryButtonEnabed
        quarantineCounterLabel.insets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        quarantineCounterLabel.layer.cornerRadius = 8
        quarantineCounterLabel.layer.masksToBounds = true

        configureAppearance()
    }

    private func configureAppearance() {
        headlineLabel.textColor = appearance.textColor
        descriptionLabel.textColor = appearance.textColor
        primaryButton.configureAppearance(textColor: appearance.textColor, arrowColor: appearance.arrowButtonColor)
        let tintedImage = closeButton.currentImage?.withRenderingMode(.alwaysTemplate)
        closeButton.imageView?.tintColor = appearance.closeButtonColor
        closeButton.setImage(tintedImage, for: .normal)
        closeButton.setImage(tintedImage, for: .disabled)
        closeButton.setImage(tintedImage, for: .highlighted)
    }

    @objc
    private func tappedView() {
        handlePrimaryTap?()
    }

    @IBAction
    private func tappedCloseButton(_ sender: Any) {
        handleClose?()
    }

    func addButton(title: String, handler: @escaping () -> Void) {
        guard buttonAction(withTitle: title) == nil else {
            return
        }

        buttonsStackView.isHidden = false

        let button = SecondaryButton(type: .custom)
        button.setAttributedTitle(title.set(style: StyleNames.secondaryButton.rawValue), for: .normal)
        button.addTarget(self, action: #selector(tappedButton), for: .touchUpInside)

        let buttonAction = ButtonAction(title: title, handler: handler)
        buttonActions.append(buttonAction)

        buttonsStackView.addArrangedSubview(button)
        buttonsStackView.isHidden = false
    }

    @objc
    private func tappedButton(_ sender: UIButton) {
        guard let buttonAction = buttonAction(withTitle: sender.titleLabel?.text) else {
            return
        }

        buttonAction.handler()
    }

    private func buttonAction(withTitle title: String?) -> ButtonAction? {
        buttonActions.first(where: { $0.title == title })
    }

    func removeButtons() {
        buttonActions.removeAll()
        buttonsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        buttonsStackView.isHidden = true
    }
}
