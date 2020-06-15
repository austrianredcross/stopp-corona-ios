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
    private let updateKeys: Bool

    init(navigationController: UINavigationController, updateKeys: Bool) {
        self.updateKeys = updateKeys
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = SicknessCertificateConfirmationViewModel(with: self, updateKeys: updateKeys)
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
