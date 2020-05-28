//
//  SavedIDsViewController.swift
//  CoronaContact
//

import UIKit
import Reusable

final class SavedIDsViewController: UIViewController, StoryboardBased, ViewModelBased, FlashableScrollIndicators {

    @IBOutlet var scrollView: UIScrollView!

    var viewModel: SavedIDsViewModel?

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
        title = "saved_IDs_title".localized
    }

    @IBAction func deleteKeysButtonTapped(_ sender: Any) {
        viewModel?.deleteExposureLog()
    }
}
