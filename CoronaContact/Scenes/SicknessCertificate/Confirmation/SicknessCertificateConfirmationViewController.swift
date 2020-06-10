//
//  SicknessCertificateConfirmationViewController.swift
//  CoronaContact
//

import Reusable
import UIKit

final class SicknessCertificateConfirmationViewController: UIViewController, StoryboardBased, ViewModelBased, FlashableScrollIndicators {
    @IBOutlet var scrollView: UIScrollView!

    var viewModel: SicknessCertificateConfirmationViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.setHidesBackButton(true, animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        flashScrollIndicators()
    }

    private func setupUI() {
        title = "sickness_certificate_confirmation_title".localized
    }

    @IBAction func secondaryButtonTapped(_ sender: UIButton) {
        viewModel?.showQuarantineGuidelines()
    }

    @IBAction func primaryButtonTapped(_ sender: UIButton) {
        viewModel?.returnToMain()
    }
}
