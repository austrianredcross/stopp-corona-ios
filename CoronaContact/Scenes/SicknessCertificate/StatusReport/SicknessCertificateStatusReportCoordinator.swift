//
//  SicknessCertificateStatusReportCoordinator.swift
//  CoronaContact
//

import UIKit

final class SicknessCertificateStatusReportCoordinator: Coordinator, ErrorPresentableCoordinator {

    lazy var rootViewController: SicknessCertificateStatusReportViewController = {
        SicknessCertificateStatusReportViewController.instantiate()
    }()

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = SicknessCertificateStatusReportViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }

    override func finish(animated: Bool = false) {
    }

    func goBackToTanConfirmation() {
        navigationController.popViewController(animated: true)
    }

    func goBackToPersonalData() {
        let personalDataViewController = navigationController.viewControllers.first { $0 is SicknessCertificatePersonalDataViewController }

        guard let viewController = personalDataViewController else {
            return
        }

        navigationController.popToViewController(viewController, animated: true)
    }

    func showConfirmation() {
        let child = SicknessCertificateConfirmationCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()
    }
}
