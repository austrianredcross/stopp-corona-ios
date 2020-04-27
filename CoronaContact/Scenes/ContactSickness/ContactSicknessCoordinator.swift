//
//  ContactSicknessCoordinator.swift
//  CoronaContact
//

import UIKit
import Resolver

final class ContactSicknessCoordinator: Coordinator {

    lazy var rootViewController: ContactSicknessViewController = {
        ContactSicknessViewController.instantiate()
    }()

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = ContactSicknessViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }

    override func finish(animated: Bool = false) {
        // if the viewController is still here this call came from the parent and we need to remove it
        if rootViewController.parent == navigationController {
            navigationController.popViewController(animated: false)
        }
        parentCoordinator?.didFinish(self)
    }
}
