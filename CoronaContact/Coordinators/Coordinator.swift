//
//  Coordinator.swift
//  CoronaContact
//

import UIKit

class Coordinator {
    private(set) var childCoordinators: [Coordinator] = []
    weak var parentCoordinator: Coordinator?

    init() {
        LoggingService.verbose(self, context: .navigation)
    }

    func start() {
        // needs to be implemented
        assertionFailure("not implemented")
    }

    func finish(animated: Bool = false) {
        // needs to be implemented and should let all views disappear ( e.g. maybe a applink was called .. )
        assertionFailure("not implemented")
    }

    func didFinish(_ coordinator: Coordinator) {
        removeChildCoordinator(coordinator)
    }

    func addChildCoordinator(_ coordinator: Coordinator) {
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
    }

    func removeChildCoordinator(_ coordinator: Coordinator) {
        if let index = childCoordinators.firstIndex(of: coordinator) {
            childCoordinators.remove(at: index)
        } else {
            LoggingService.debug("Couldn't remove coordinator: \(coordinator). It's not a child coordinator.", context: .navigation)
        }
    }

    deinit {
        LoggingService.verbose(self, context: .navigation)
    }
}

extension Coordinator: Equatable {
    static func == (lhs: Coordinator, rhs: Coordinator) -> Bool {
        lhs === rhs
    }
}

// MARK: - Error handling

protocol ErrorPresentableCoordinator {
    associatedtype ViewController: UIViewController

    var rootViewController: ViewController { get set }
}

extension ErrorPresentableCoordinator where Self: Coordinator {
    func showErrorAlert(title: String? = nil, error: String? = nil, closeButtonTitle: String? = nil, closeAction: ((UIAlertAction) -> Void)? = nil) {
        let closeAction = UIAlertAction(title: closeButtonTitle ?? "general_ok".localized, style: .default, handler: closeAction)
        let alertViewController = UIAlertController(title: title, message: error, preferredStyle: .alert)
        alertViewController.addAction(closeAction)

        let presentAlert = {
            self.rootViewController.present(alertViewController, animated: true)
        }

        if let presentedViewController = rootViewController.presentedViewController {
            presentedViewController.dismiss(animated: true) {
                presentAlert()
            }
        } else {
            presentAlert()
        }
    }

    func showGenericErrorAlert(closeButtonTitle: String? = nil, closeAction: ((UIAlertAction) -> Void)? = nil) {
        showErrorAlert(
            title: "general_server_error".localized,
            error: "general_server_connection_error_description".localized,
            closeAction: closeAction
        )
    }
}
