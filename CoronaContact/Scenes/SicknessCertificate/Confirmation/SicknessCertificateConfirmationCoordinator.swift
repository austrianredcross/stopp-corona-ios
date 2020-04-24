//
//  SicknessCertificateConfirmationCoordinator.swift
//  CoronaContact
//

import UIKit

final class SicknessCertificateConfirmationCoordinator: Coordinator {

    lazy var rootViewController: SicknessCertificateConfirmationViewController = {
        SicknessCertificateConfirmationViewController.instantiate()
    }()

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = SicknessCertificateConfirmationViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }

    override func finish(animated: Bool = false) {
        navigationController.popToRootViewController(animated: animated)
        parentCoordinator?.didFinish(self)
    }

    func showQuarantineGuidelines() {
        let child = QuarantineGuidelinesCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()
    }
}
