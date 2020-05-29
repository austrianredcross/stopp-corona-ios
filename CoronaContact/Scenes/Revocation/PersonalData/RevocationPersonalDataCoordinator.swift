//
//  RevocationPersonalDataCoordinator.swift
//  CoronaContact
//

import UIKit

final class RevocationPersonalDataCoordinator: Coordinator, ErrorPresentableCoordinator {
    lazy var rootViewController: RevocationPersonalDataViewController = {
        RevocationPersonalDataViewController.instantiate()
    }()

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = RevocationPersonalDataViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }

    override func finish(animated: Bool = false) {
        // if the viewController is still here this call came from the parent and we need to remove it
        if rootViewController.parent == navigationController {
            navigationController.popViewController(animated: false)
        }
        parentCoordinator?.didFinish(self)
    }

    func tanConfirmation() {
        let child = RevocationTanConfirmationCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()
    }
}
