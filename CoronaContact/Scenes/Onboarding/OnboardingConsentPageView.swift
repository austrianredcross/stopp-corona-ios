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
    @IBOutlet var checkbox: M13Checkbox!
    @IBOutlet var consentLabel: TransLabel!
    @IBOutlet var textLabel2: UILabel!
    @IBOutlet var button: TransButton!

    weak var viewModel: OnboardingViewModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        checkbox.boxType = .square
        checkbox.markType = .checkmark
        checkbox.stateChangeAnimation = .bounce(.fill)
        checkbox.tintColor = .ccRouge
        checkbox.checkmarkLineWidth = 2
        checkbox.boxLineWidth = 2
        checkbox.secondaryTintColor = .black

        let tap = UITapGestureRecognizer(target: self, action: #selector(toogleAgreement(_:)))
        consentLabel.addGestureRecognizer(tap)
    }

    @objc func toogleAgreement(_ sender: UITapGestureRecognizer) {
        checkbox.toggleCheckState()
        agreementChanged(checkbox)
    }

    @IBAction func agreementChanged(_ sender: M13Checkbox) {
        let isChecked = sender.checkState == .checked
        viewModel?.agreementToDataPrivacy = isChecked
    }

    @IBAction func dataPrivacyButtonTapped(_ sender: Any) {
        viewModel?.dataPrivacy()
    }
}
