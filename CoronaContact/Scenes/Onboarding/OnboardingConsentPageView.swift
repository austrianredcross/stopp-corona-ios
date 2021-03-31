//
//  OnboardingConsentPageView.swift
//  CoronaContact
//

import M13Checkbox
import Reusable
import UIKit

final class OnboardingConsentPageView: UIView, NibLoadable {


    @IBOutlet var headingLabel: TransHeadingLabel!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var checkboxLabelView: CheckboxLabelView!
    @IBOutlet var textLabel2: UILabel!
    @IBOutlet var textView: LinkTextView!
    weak var viewModel: OnboardingViewModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        
        checkboxLabelView.handleTap = { [weak self] (value) in
            self?.viewModel?.agreementToDataPrivacy = value
        }
        
        textView.textViewAttribute = TextViewAttribute(fullText: "onboarding_consent_body_3".localized, links: [DeepLinkConstants.deepLinkPrivacyUrl], linkColor: .ccLink)
    }

    @objc func toogleAgreement(_ sender: UITapGestureRecognizer) {
        checkboxLabelView.checkbox.toggleCheckState()
        agreementChanged(value: checkboxLabelView.checkbox.checkState == .checked)
    }
    
    private func agreementChanged(value: Bool) {
        viewModel?.agreementToDataPrivacy = value
    }
}
