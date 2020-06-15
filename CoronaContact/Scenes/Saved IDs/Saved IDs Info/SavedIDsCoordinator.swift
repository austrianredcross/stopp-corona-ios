//
//  SavedIDsCoordinator.swift
//  CoronaContact
//

import UIKit

final class SavedIDsCoordinator: Coordinator {
    // MARK: - Properties

    private lazy var rootViewController: SavedIDsViewController = {
        let controller = SavedIDsViewController.instantiate()
        controller.viewModel = SavedIDsViewModel(self)
        return controller
    }()

    let navigationController: UINavigationController

    // MARK: - Lifecycle

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Coordination

    override func start() {
        navigationController.pushViewController(rootViewController, animated: true)
    }

    // MARK: - Housekeeping

    override func finish(animated: Bool = false) {
        parentCoordinator?.didFinish(self)
    }
}
