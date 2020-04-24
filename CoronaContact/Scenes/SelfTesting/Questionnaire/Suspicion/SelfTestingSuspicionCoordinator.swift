//
//  SelfTestingSuspicionCoordinator.swift
//  CoronaContact
//

import UIKit

final class SelfTestingSuspicionCoordinator: Coordinator {

    lazy var rootViewController: SelfTestingSuspicionViewController = {
        SelfTestingSuspicionViewController.instantiate()
    }()

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = SelfTestingSuspicionViewModel(with: self)
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

    func report() {
        let child = SelfTestingPersonalDataCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()
    }
}
