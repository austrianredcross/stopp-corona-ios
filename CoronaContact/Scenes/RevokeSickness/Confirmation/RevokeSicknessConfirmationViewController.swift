//
//  RevokeSicknessConfirmationViewController.swift
//  CoronaContact
//

import UIKit
import Reusable

final class RevokeSicknessConfirmationViewController: UIViewController, StoryboardBased, ViewModelBased, FlashableScrollIndicators {

    @IBOutlet weak var scrollView: UIScrollView!

    var viewModel: RevokeSicknessConfirmationViewModel?

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
        title = "revoke_sickness_title".localized
    }

    @IBAction func buttonTapped(_ sender: Any) {
        viewModel?.returnToMain()
    }
}
