//
//  SavedIDsViewController.swift
//  CoronaContact
//

import UIKit
import Reusable

final class SavedIDsViewController: UIViewController, StoryboardBased, ViewModelBased, FlashableScrollIndicators {

    @IBOutlet weak var scrollView: UIScrollView!

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
        let alert = UIAlertController(title: "saved_IDs_delete_alert_title".localized,
                                      message: "saved_IDs_delete_alert_message".localized,
                                      preferredStyle: .alert)

        let delete = UIAlertAction(title: "saved_IDs_delete_alert_delete_button".localized,
                                   style: .destructive,
                                   handler: { [viewModel] _ in viewModel?.deleteAll() })
        let cancel = UIAlertAction(title: "general_cancel".localized,
                                   style: .cancel,
                                   handler: nil)

        alert.addAction(delete)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
}
