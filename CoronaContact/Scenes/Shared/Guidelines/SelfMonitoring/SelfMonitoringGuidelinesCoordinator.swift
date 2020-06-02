//
//  SelfMonitoringGuidelinesCoordinator.swift
//  CoronaContact
//

import UIKit

final class SelfMonitoringGuidelinesCoordinator: Coordinator {
    lazy var rootViewController: SelfMonitoringGuidelinesViewController = {
        SelfMonitoringGuidelinesViewController.instantiate()
    }()

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = SelfMonitoringGuidelinesViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }

    override func finish(animated: Bool = false) {
        parentCoordinator?.didFinish(self)
    }

    func selfTesting() {
        let child = SelfTestingCheckSymptomsCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start(with: 0)
    }
}
