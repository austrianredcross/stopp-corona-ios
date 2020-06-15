//
//  RevokeSicknessPersonalDataCoordinator.swift
//  CoronaContact
//

import UIKit

final class RevokeSicknessPersonalDataCoordinator: Coordinator, ErrorPresentableCoordinator {
    lazy var rootViewController: RevokeSicknessPersonalDataViewController = {
        RevokeSicknessPersonalDataViewController.instantiate()
    }()

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = RevokeSicknessPersonalDataViewModel(with: self)
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
        let child = RevokeSicknessTanConfirmationCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()
    }
}
