//
//  SelfTestingStatusReportViewController.swift
//  CoronaContact
//

import UIKit
import Reusable
import M13Checkbox

final class SelfTestingStatusReportViewController: UIViewController,
    StoryboardBased, ViewModelBased, ActivityModalPresentable, FlashableScrollIndicators {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var checkbox: M13Checkbox!
    @IBOutlet weak var reportButton: UIButton!

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
        title = "self_testing_report_status_title".localized
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
