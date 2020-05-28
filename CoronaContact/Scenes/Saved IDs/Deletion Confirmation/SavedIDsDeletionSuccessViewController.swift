//
//  SavedIDsDeletionConfirmationViewController.swift
//  CoronaContact
//

import UIKit
import Reusable

final class SavedIDsDeletionSuccessViewController: UIViewController, StoryboardBased, ViewModelBased, FlashableScrollIndicators {

    @IBOutlet weak var scrollView: UIScrollView!

    var viewModel: SavedIDsDeletionConfirmationViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        flashScrollIndicators()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if navigationController == nil {
            viewModel?.finish()
        }
    }

    private func setupUI() {
        title = "saved_IDs_deletion_confirmation_title".localized
    }

    @IBAction func backToStartButtonTapped(_ sender: Any) {
        viewModel?.deletionConfirmationAcknowledged()
    }
}
