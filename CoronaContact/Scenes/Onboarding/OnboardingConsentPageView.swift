//
//  OnboardingConsentPageView.swift
//  CoronaContact
//

import M13Checkbox
import Reusable
import UIKit

final class OnboardingConsentPageView: UIView, NibLoadable {


    @IBOutlet var headingLabel: UILabel!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var checkboxLabelView: CheckboxLabelView!
    @IBOutlet var textLabel2: UILabel!
    @IBOutlet var button: TransButton!

    weak var viewModel: OnboardingViewModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        
        checkboxLabelView.awakeFromNib()
        checkboxLabelView.checkbox.boxType = .square
        checkboxLabelView.checkbox.markType = .checkmark
        checkboxLabelView.checkbox.stateChangeAnimation = .bounce(.fill)
        checkboxLabelView.checkbox.tintColor = .ccRouge
        checkboxLabelView.checkbox.checkmarkLineWidth = 2
        checkboxLabelView.checkbox.boxLineWidth = 2
        checkboxLabelView.checkbox.secondaryTintColor = .black

        let tap = UITapGestureRecognizer(target: self, action: #selector(toogleAgreement(_:)))
        checkboxLabelView.label.addGestureRecognizer(tap)
        
        checkboxLabelView.handleTap = { [weak self] (value) in
            self?.viewModel?.agreementToDataPrivacy = value
        }
    }

    @objc func toogleAgreement(_ sender: UITapGestureRecognizer) {
        checkboxLabelView.checkbox.toggleCheckState()
        agreementChanged(value: checkboxLabelView.checkbox.checkState == .checked)
    }
    
    private func agreementChanged(value: Bool) {
        viewModel?.agreementToDataPrivacy = value
    }

    @IBAction func dataPrivacyButtonTapped(_ sender: Any) {
        viewModel?.dataPrivacy()
    }
}
