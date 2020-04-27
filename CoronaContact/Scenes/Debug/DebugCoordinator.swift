//
// DebugCoordinator.swift
// CoronaContact
//

import UIKit

class DebugCoordinator: Coordinator {
    var navigationController: UINavigationController

    lazy var rootViewController: UINavigationController = {
        let viewController = DebugViewController.instantiate(with: DebugViewModel(coordintator: self))
        let controller = UINavigationController(rootViewController: viewController)
        return controller

    }()

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.modalPresentationStyle = .fullScreen
        navigationController.present(rootViewController, animated: true, completion: nil)
    }

    override func finish(animated: Bool = false) {
        if rootViewController.presentingViewController == navigationController {
            navigationController.dismiss(animated: animated) {
                self.parentCoordinator?.didFinish(self)
            }
        } else {
            parentCoordinator?.didFinish(self)
        }
    }

    func shareLog() {
        let activityViewController = UIActivityViewController(activityItems: [LoggingService.logFileURL], applicationActivities: nil)
        rootViewController.present(activityViewController, animated: true, completion: nil)
    }
}
