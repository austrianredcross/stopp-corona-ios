//
//  QuarantineGuidelinesCoordinator.swift
//  CoronaContact
//

import Resolver
import UIKit

final class QuarantineGuidelinesCoordinator: Coordinator {
    lazy var rootViewController: QuarantineGuidelinesViewController = {
        QuarantineGuidelinesViewController.instantiate()
    }()

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = QuarantineGuidelinesViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }

    override func finish(animated: Bool = false) {
        navigationController.popToRootViewController(animated: animated)
        parentCoordinator?.didFinish(self)
    }
}
