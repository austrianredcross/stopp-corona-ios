//
//  SuspicionGuidelinesCoordinator.swift
//  CoronaContact
//

import UIKit

final class SuspicionGuidelinesCoordinator: Coordinator {

    lazy var rootViewController: SuspicionGuidelinesViewController = {
        SuspicionGuidelinesViewController.instantiate()
    }()

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = SuspicionGuidelinesViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }

    override func finish(animated: Bool = false) {
        parentCoordinator?.didFinish(self)
    }

    func reportSick() {
        let child = SicknessCertificateCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()
    }
}
