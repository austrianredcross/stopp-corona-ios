//
//  RevokeSicknessStatusReportViewController.swift
//  CoronaContact
//

import Reusable
import UIKit

final class RevokeSicknessStatusReportViewController: UIViewController,
    StoryboardBased, ViewModelBased, ActivityModalPresentable, FlashableScrollIndicators {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var descriptionLabel: TransLabel!
    @IBOutlet var checkboxLabelView: CheckboxLabelView!
    @IBOutlet var reportStatusButton: UIButton!

    var viewModel: RevokeSicknessStatusReportViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        flashScrollIndicators()
    }

    private func setupUI() {
        title = "revoke_sickness_title".localized

        if let dateLabel = viewModel?.dateLabel, let transKey = descriptionLabel.transKey {
            descriptionLabel.styledText = String(format: transKey.localized, dateLabel)
        }

        checkboxLabelView.handleTap = { [weak self] isChecked in
            self?.agreementChanged(isChecked)
        }

        reportStatusButton.isEnabled = false
    }

    private func agreementChanged(_ isChecked: Bool) {
        viewModel?.agreesToTerms = isChecked
        reportStatusButton.isEnabled = isChecked
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
