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
    let updateKeys: Bool

    init(navigationController: UINavigationController, updateKeys: Bool) {
        self.navigationController = navigationController
        self.updateKeys = updateKeys
    }

    override func start() {
        rootViewController.viewModel = SelfTestingConfirmationViewModel(with: self, updateKeys: updateKeys)
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
