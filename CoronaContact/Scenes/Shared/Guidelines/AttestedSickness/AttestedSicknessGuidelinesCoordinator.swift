//
//  AttestedSicknessGuidelinesCoordinator.swift
//  CoronaContact
//

import UIKit

final class AttestedSicknessGuidelinesCoordinator: Coordinator {
    lazy var rootViewController: AttestedSicknessGuidelinesViewController = {
        AttestedSicknessGuidelinesViewController.instantiate()
    }()

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = AttestedSicknessGuidelinesViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }

    override func finish(animated: Bool = false) {
        navigationController.popViewController(animated: animated)
        parentCoordinator?.didFinish(self)
    }
}
