//
//  SavedIDsCoordinator.swift
//  CoronaContact
//

import UIKit

final class SavedIDsCoordinator: Coordinator {

    private lazy var rootViewController: SavedIDsViewController = {
        SavedIDsViewController.instantiate()
    }()

    let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = SavedIDsViewModel(self)
        navigationController.pushViewController(rootViewController, animated: true)
    }

    override func finish(animated: Bool = false) {
        parentCoordinator?.didFinish(self)
    }
}
