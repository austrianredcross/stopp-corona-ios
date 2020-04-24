//
//  SelfTestingCoordinator.swift
//  CoronaContact
//

import UIKit

class SelfTestingCoordinator: Coordinator {

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        if UserDefaults.standard.agreedToMedicalDataPrivacyAt == nil {
            let child = SelfTestingConsentCoordinator(navigationController: navigationController)
            addChildCoordinator(child)
            child.start()
        } else {
            let child = SelfTestingCheckSymptomsCoordinator(navigationController: navigationController)
            addChildCoordinator(child)
            child.start(with: 0)
        }
    }

    override func finish(animated: Bool = false) {
        parentCoordinator?.didFinish(self)
    }
}
