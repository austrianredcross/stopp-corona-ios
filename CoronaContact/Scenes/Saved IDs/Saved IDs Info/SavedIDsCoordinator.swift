//
//  SavedIDsCoordinator.swift
//  CoronaContact
//

import UIKit

final class SavedIDsCoordinator: Coordinator {

    private lazy var rootViewController: SavedIDsViewController = {
        let controller = SavedIDsViewController.instantiate()
        controller.viewModel = SavedIDsViewModel(self)
        return controller
    }()

    private func confirmationViewController() -> SavedIDsDeletionConfirmationViewController {
        let controller = SavedIDsDeletionConfirmationViewController.instantiate()
        controller.viewModel = SavedIDsDeletionConfirmationViewModel(self)
        return controller
    }

    let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        navigationController.pushViewController(rootViewController, animated: true)
    }

    func didDeleteKeys() {
        let controller = confirmationViewController()
        controller.modalPresentationStyle = .fullScreen
        navigationController.present(controller, animated: true, completion: nil)
    }

    func deletionConfirmationAcknowledged() {

    }

    override func finish(animated: Bool = false) {
        parentCoordinator?.didFinish(self)
    }
}
