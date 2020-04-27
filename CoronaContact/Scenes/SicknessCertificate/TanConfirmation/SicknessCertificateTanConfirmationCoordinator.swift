//
//  SicknessCertificateTanConfirmationCoordinator.swift
//  CoronaContact
//

import UIKit

final class SicknessCertificateTanConfirmationCoordinator: Coordinator, ErrorPresentableCoordinator {

    lazy var rootViewController: SicknessCertificateTanConfirmationViewController = {
        SicknessCertificateTanConfirmationViewController.instantiate()
    }()

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = SicknessCertificateTanConfirmationViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }

    override func finish(animated: Bool = false) {
    }

    func reportStatus() {
        let child = SicknessCertificateStatusReportCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()
    }
}
