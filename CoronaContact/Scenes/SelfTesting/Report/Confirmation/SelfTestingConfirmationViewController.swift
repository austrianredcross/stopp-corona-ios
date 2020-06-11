//
//  SelfTestingConfirmationViewController.swift
//  CoronaContact
//

import Reusable
import UIKit

final class SelfTestingConfirmationViewController: UIViewController, StoryboardBased, ViewModelBased, FlashableScrollIndicators {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var confirmationHeadline: TransLabel!
    @IBOutlet var confirmationDescription: TransLabel!

    var viewModel: SelfTestingConfirmationViewModel?

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
        let updateKeys = viewModel?.updateKeys ?? false

        if updateKeys {
            title = "self_testing_confirmation_title_extra".localized
            confirmationHeadline.styledText = "self_testing_confirmation_headline_extra".localized
            confirmationDescription.styledText = "self_testing_confirmation_description_extra".localized
        } else {
            title = "self_testing_confirmation_title".localized
        }
    }

    @IBAction func secondaryButtonTapped(_ sender: UIButton) {
        viewModel?.showQuarantineGuidelines()
    }

    @IBAction func primaryButtonTapped(_ sender: UIButton) {
        viewModel?.returnToMain()
    }
}
