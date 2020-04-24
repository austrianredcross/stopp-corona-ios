//
//  RevocationConfirmationViewController.swift
//  CoronaContact
//

import UIKit
import Reusable

final class RevocationConfirmationViewController: UIViewController, StoryboardBased, ViewModelBased, FlashableScrollIndicators {

    @IBOutlet weak var scrollView: UIScrollView!

    var viewModel: RevocationConfirmationViewModel?

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
        title = "revocation_confirmation_title".localized
    }

    @IBAction func buttonTapped(_ sender: Any) {
        viewModel?.returnToMain()
    }
}
