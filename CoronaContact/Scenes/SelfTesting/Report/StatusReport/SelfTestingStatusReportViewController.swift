//
//  SelfTestingStatusReportViewController.swift
//  CoronaContact
//

import M13Checkbox
import Reusable
import UIKit

final class SelfTestingStatusReportViewController: UIViewController,
    StoryboardBased, ViewModelBased, ActivityModalPresentable, FlashableScrollIndicators {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var checkbox: M13Checkbox!
    @IBOutlet var reportButton: PrimaryButton!
    @IBOutlet var statusHeadline: TransLabel!
    @IBOutlet var statusDescription: TransLabel!

    var viewModel: SelfTestingStatusReportViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        flashScrollIndicators()
    }

    private func setupUI() {
        let updateKeys = viewModel?.updateKeys ?? false

        if updateKeys {
            title = "self_testing_report_status_title_extra".localized
            statusHeadline.styledText = "self_testing_report_status_headline".localized
            statusDescription.styledText = "self_testing_report_status_description_extra".localized
            reportButton.transKeyNormal = "self_testing_report_status_button_extra"
            reportButton.updateTranslation()
        } else {
            title = "self_testing_report_status_title".localized
        }
        reportButton.isEnabled = false

        checkbox.boxType = .square
        checkbox.markType = .checkmark
        checkbox.stateChangeAnimation = .bounce(.fill)
        checkbox.tintColor = .ccRouge
        checkbox.checkmarkLineWidth = 2
        checkbox.boxLineWidth = 2
        checkbox.secondaryTintColor = .black
    }

    @IBAction func agreementChanged(_ sender: M13Checkbox) {
        let isChecked = sender.checkState == .checked
        viewModel?.agreesToTerms = isChecked
        reportButton.isEnabled = isChecked
    }

    @IBAction func reportButtonTapped(_ sender: UIButton) {
        guard viewModel?.isValid == true else {
            return
        }

        showActivity()
        viewModel?.goToNext(completion: { [weak self] in
            self?.hideActivity()
        })
    }
}
