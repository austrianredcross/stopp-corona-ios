//
//  RevocationConfirmationCoordinator.swift
//  CoronaContact
//

import UIKit

final class RevocationConfirmationCoordinator: Coordinator {
    lazy var rootViewController: RevocationConfirmationViewController = {
        RevocationConfirmationViewController.instantiate()
    }()

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = RevocationConfirmationViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }

    override func finish(animated: Bool = false) {
        navigationController.popToRootViewController(animated: animated)
        parentCoordinator?.didFinish(self)
    }
}
