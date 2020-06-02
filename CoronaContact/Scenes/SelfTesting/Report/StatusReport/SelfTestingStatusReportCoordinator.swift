//
//  SelfTestingStatusReportCoordinator.swift
//  CoronaContact
//

import UIKit

final class SelfTestingStatusReportCoordinator: Coordinator, ErrorPresentableCoordinator {
    lazy var rootViewController: SelfTestingStatusReportViewController = {
        SelfTestingStatusReportViewController.instantiate()
    }()

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = SelfTestingStatusReportViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }

    override func finish(animated: Bool = false) {}

    func goBackToTanConfirmation() {
        navigationController.popViewController(animated: true)
    }

    func goBackToPersonalData() {
        let personalDataViewController = navigationController.viewControllers.first { $0 is SelfTestingPersonalDataViewController }

        guard let viewController = personalDataViewController else {
            return
        }

        navigationController.popToViewController(viewController, animated: true)
    }

    func showConfirmation() {
        let child = SelfTestingConfirmationCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()
    }
}
