//
//  SelfTestingHintCoordinator.swift
//  CoronaContact
//

import UIKit

final class SelfTestingHintCoordinator: Coordinator {

    lazy var rootViewController: SelfTestingHintViewController = {
        SelfTestingHintViewController.instantiate()
    }()

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = SelfTestingHintViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }

    override func finish(animated: Bool = false) {
        parentCoordinator?.didFinish(self)
    }

    func popToRoot(animated: Bool = true) {
        navigationController.popToRootViewController(animated: animated)
        parentCoordinator?.didFinish(self)
        parentCoordinator?.finish(animated: animated)
    }
}
