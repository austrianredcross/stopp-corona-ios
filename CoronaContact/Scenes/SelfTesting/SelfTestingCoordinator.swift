//
//  SelfTestingCoordinator.swift
//  CoronaContact
//

import UIKit
import Resolver

class SelfTestingCoordinator: Coordinator {
    
    @Injected private var localStorage: LocalStorage
    
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        if localStorage.missingUploadedKeysAt != nil {
            let child = SelfTestingPersonalDataCoordinator(navigationController: navigationController)
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
