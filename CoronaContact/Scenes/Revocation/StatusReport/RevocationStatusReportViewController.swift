//
//  RevocationStatusReportViewController.swift
//  CoronaContact
//

import Reusable
import UIKit

final class RevocationStatusReportViewController: UIViewController,
    StoryboardBased, ViewModelBased, ActivityModalPresentable, FlashableScrollIndicators
{
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var descriptionLabel: TransLabel!
    @IBOutlet var checkboxLabelView: CheckboxLabelView!
    @IBOutlet var reportStatusButton: UIButton!

    var viewModel: RevocationStatusReportViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        flashScrollIndicators()
    }

    private func setupUI() {
        title = "revocation_report_status_title".localized

        if let dateLabel = viewModel?.dateLabel {
            descriptionLabel.styledText = String(format: "revocation_report_status_description".localized, dateLabel)
        }

        checkboxLabelView.handleTap = { [weak self] isChecked in
            self?.agreementChanged(isChecked)
        }

        reportStatusButton.isEnabled = false
        reportStatusButton.accessibilityHint = "accessibility_revokation_report_status_button_disabled_description".localized
    }

    private func agreementChanged(_ isChecked: Bool) {
        viewModel?.agreesToTerms = isChecked
        reportStatusButton.isEnabled = isChecked
        reportStatusButton.accessibilityHint = isChecked ? nil : "accessibility_revokation_report_status_button_disabled_description".localized
    }

    @IBAction private func reportButtonTapped(_ sender: Any) {
        guard viewModel?.isValid == true else {
            return
        }

        showActivity()
        viewModel?.goToNext(completion: { [weak self] in
            self?.hideActivity()
        })
    }
}
