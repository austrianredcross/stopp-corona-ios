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
    private let updateKeys: Bool

    init(navigationController: UINavigationController, updateKeys: Bool) {
        self.navigationController = navigationController
        self.updateKeys = updateKeys
    }

    override func start() {
        rootViewController.viewModel = SicknessCertificateTanConfirmationViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }

    override func finish(animated: Bool = false) {}

    func reportStatus() {
        let child = SicknessCertificateStatusReportCoordinator(navigationController: navigationController, updateKeys: updateKeys)
        addChildCoordinator(child)
        child.start()
    }
}
