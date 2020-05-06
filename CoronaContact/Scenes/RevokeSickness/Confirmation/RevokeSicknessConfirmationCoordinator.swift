//
//  RevokeSicknessConfirmationCoordinator.swift
//  CoronaContact
//

import UIKit

final class RevokeSicknessConfirmationCoordinator: Coordinator {

    lazy var rootViewController: RevokeSicknessConfirmationViewController = {
        RevokeSicknessConfirmationViewController.instantiate()
    }()

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = RevokeSicknessConfirmationViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }

    override func finish(animated: Bool = false) {
        navigationController.popToRootViewController(animated: animated)
        parentCoordinator?.didFinish(self)
    }
}
