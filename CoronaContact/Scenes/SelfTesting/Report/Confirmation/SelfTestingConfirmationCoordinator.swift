//
//  SelfTestingConfirmationCoordinator.swift
//  CoronaContact
//

import UIKit

final class SelfTestingConfirmationCoordinator: Coordinator {
    lazy var rootViewController: SelfTestingConfirmationViewController = {
        SelfTestingConfirmationViewController.instantiate()
    }()

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = SelfTestingConfirmationViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }

    override func finish(animated: Bool = false) {
        navigationController.popToRootViewController(animated: animated)
        parentCoordinator?.didFinish(self)
    }

    func showQuarantineGuidelines() {
        let child = QuarantineGuidelinesCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()
    }
}
