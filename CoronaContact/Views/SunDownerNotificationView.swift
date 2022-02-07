//
//  SunDownerNotificationView.swift
//  CoronaContact
//

import Reusable
import UIKit

class SunDownerNotificationView: UIView, NibOwnerLoadable {

    @IBInspectable var icon: UIImage? {
        didSet {
            if let icon = icon {
                iconImageView.image = icon.withRenderingMode(.alwaysTemplate)
                iconImageView.tintColor = appearance.textColor
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

    @IBInspectable var descriptionFirstText: String = "" {
        didSet {
            descriptionLabelFirst.styledText = descriptionFirstText
            descriptionLabelFirst.textColor = appearance.textColor
        }
    }
    
    
    @IBInspectable var descriptionSecondText: String = "" {
        didSet {
            descriptionLabelSecond.styledText = descriptionSecondText
            descriptionLabelSecond.textColor = appearance.textColor
        }
    }

    var appearance: QuarantineNotificationAppearance = .color {
        didSet {
            configureAppearance()
        }
    }
    
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var innerView: UIView!
    @IBOutlet var headlineLabel: TransHeadingLabel!
    @IBOutlet var descriptionLabelFirst: TransLabel!
    @IBOutlet var descriptionLabelSecond: TransLabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        loadNibContent()
        configureView()
    }

    private func configureView() {
        innerView.layer.cornerRadius = 10
        innerView.addStandardShadow()
        
        headlineText = "sunDowner_notification_title".localized
        descriptionFirstText = String(format: "sunDowner_notification_content".localized, Date().sundDownerDate.shortDayShortMonthLongYear)
        descriptionSecondText = "sunDowner_notification_content_2".localized

        innerView.backgroundColor = .ccGreen
        configureAppearance()
    }

    private func configureAppearance() {
        headlineLabel.textColor = appearance.textColor
        descriptionLabelFirst.textColor = appearance.textColor
        descriptionLabelSecond.textColor = appearance.textColor
    }
}
