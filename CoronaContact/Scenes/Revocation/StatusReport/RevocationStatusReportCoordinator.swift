//
//  RevocationStatusReportCoordinator.swift
//  CoronaContact
//

import UIKit

final class RevocationStatusReportCoordinator: Coordinator, ErrorPresentableCoordinator {
    lazy var rootViewController: RevocationStatusReportViewController = {
        RevocationStatusReportViewController.instantiate()
    }()

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = RevocationStatusReportViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }

    override func finish(animated: Bool = false) {}

    func goBackToTanConfirmation() {
        navigationController.popViewController(animated: true)
    }

    func goBackToPersonalData() {
        let personalDataViewController = navigationController.viewControllers.first { $0 is RevocationPersonalDataViewController }

        guard let viewController = personalDataViewController else {
            return
        }

        navigationController.popToViewController(viewController, animated: true)
    }

    func showConfirmation() {
        let child = RevocationConfirmationCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()
    }
}
