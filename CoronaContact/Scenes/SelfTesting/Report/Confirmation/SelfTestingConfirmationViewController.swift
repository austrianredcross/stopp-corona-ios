//
//  SelfTestingConfirmationViewController.swift
//  CoronaContact
//

import Reusable
import UIKit

final class SelfTestingConfirmationViewController: UIViewController, StoryboardBased, ViewModelBased, FlashableScrollIndicators {
    @IBOutlet var scrollView: UIScrollView!

    var viewModel: SelfTestingConfirmationViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel?.onViewDidLoad()

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
        title = "self_testing_confirmation_title".localized
    }

    @IBAction func secondaryButtonTapped(_ sender: UIButton) {
        viewModel?.showQuarantineGuidelines()
    }

    @IBAction func primaryButtonTapped(_ sender: UIButton) {
        viewModel?.returnToMain()
    }
}
