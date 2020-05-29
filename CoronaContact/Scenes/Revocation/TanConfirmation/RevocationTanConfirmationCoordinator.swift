//
//  RevocationTanConfirmationCoordinator.swift
//  CoronaContact
//

import UIKit

final class RevocationTanConfirmationCoordinator: Coordinator, ErrorPresentableCoordinator {
    lazy var rootViewController: RevocationTanConfirmationViewController = {
        RevocationTanConfirmationViewController.instantiate()
    }()

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = RevocationTanConfirmationViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }

    override func finish(animated: Bool = false) {
        navigationController.popViewController(animated: animated)
    }

    func reportStatus() {
        let child = RevocationStatusReportCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()
    }
}
