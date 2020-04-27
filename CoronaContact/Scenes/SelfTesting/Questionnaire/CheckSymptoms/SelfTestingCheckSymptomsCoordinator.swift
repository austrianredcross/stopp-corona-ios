//
//  SelfTestingCheckSymptomsCoordinator.swift
//  CoronaContact
//

import UIKit

final class SelfTestingCheckSymptomsCoordinator: Coordinator {

    lazy var rootViewController: SelfTestingCheckSymptomsViewController = {
        SelfTestingCheckSymptomsViewController.instantiate()
    }()

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start(with index: Int) {
        rootViewController.viewModel = SelfTestingCheckSymptomsViewModel(with: self, questionIndex: index)
        navigationController.pushViewController(rootViewController, animated: true)
    }

    override func finish(animated: Bool = false) {
        parentCoordinator?.didFinish(self)
    }

    func nextPage(_ nextStep: Decision, at index: Int) {
        let child: Coordinator

        switch nextStep {
        case .nextQuestion:
            let child = SelfTestingCheckSymptomsCoordinator(navigationController: navigationController)
            addChildCoordinator(child)
            child.start(with: index)
            return

        case .hint:
            child = SelfTestingHintCoordinator(navigationController: navigationController)
        case .selfMonitoring:
            child = SelfTestingSelfMonitoringCoordinator(navigationController: navigationController)
        case .suspected:
            child = SelfTestingSuspicionCoordinator(navigationController: navigationController)
        }

        addChildCoordinator(child)
        child.start()
    }
}
