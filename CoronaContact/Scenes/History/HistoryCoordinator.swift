//
//  HistoryCoordinator.swift
//  CoronaContact
//

import UIKit

class HistoryCoordinator: Coordinator {
    var navigationController: UINavigationController

    lazy var rootViewController: HistoryViewController = {
        HistoryViewController.instantiate()
    }()

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = HistoryViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }

    override func finish(animated: Bool = false) {
        if rootViewController.parent == navigationController {
            navigationController.popViewController(animated: false)
        }
        parentCoordinator?.didFinish(self)
    }
}
