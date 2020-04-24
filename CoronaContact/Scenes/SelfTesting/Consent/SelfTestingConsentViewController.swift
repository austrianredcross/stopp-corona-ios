//
//  SelfTestingConsentViewController.swift
//  CoronaContact
//

import UIKit
import Reusable

final class SelfTestingConsentViewController: UIViewController, StoryboardBased, ViewModelBased, FlashableScrollIndicators {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var checkboxLabelView: CheckboxLabelView!
    @IBOutlet weak var consentButton: UIButton!

    var viewModel: SelfTestingConsentViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        flashScrollIndicators()
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            viewModel?.viewClosed()
        }
    }

    private func setupUI() {
        checkboxLabelView.handleTap = { [weak self] isChecked in
            self?.agreementChanged(isChecked)
        }

        consentButton.isEnabled = false
    }

    private func agreementChanged(_ isChecked: Bool) {
        viewModel?.agreementToMedicalDataPrivacy = isChecked
        consentButton.isEnabled = isChecked
    }

    @IBAction private func consentButtonTapped(_ sender: Any) {
        viewModel?.consentButtonTapped()
    }

    @IBAction func dataPrivacyButtonTapped(_ sender: Any) {
        viewModel?.dataPrivacy()
    }
}
