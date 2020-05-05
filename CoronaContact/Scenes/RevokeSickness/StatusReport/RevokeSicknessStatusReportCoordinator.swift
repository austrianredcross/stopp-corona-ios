//
//  RevokeSicknessStatusReportCoordinator.swift
//  CoronaContact
//

import UIKit

final class RevokeSicknessStatusReportCoordinator: Coordinator, ErrorPresentableCoordinator {

    lazy var rootViewController: RevokeSicknessStatusReportViewController = {
        RevokeSicknessStatusReportViewController.instantiate()
    }()

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = RevokeSicknessStatusReportViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }

    override func finish(animated: Bool = false) {
    }

    func goBackToTanConfirmation() {
        navigationController.popViewController(animated: true)
    }

    func goBackToPersonalData() {
        let personalDataViewController = navigationController.viewControllers.first { $0 is RevokeSicknessPersonalDataViewController }

        guard let viewController = personalDataViewController else {
            return
        }

        navigationController.popToViewController(viewController, animated: true)
    }

    func showConfirmation() {
        let child = RevokeSicknessConfirmationCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()
    }
}
