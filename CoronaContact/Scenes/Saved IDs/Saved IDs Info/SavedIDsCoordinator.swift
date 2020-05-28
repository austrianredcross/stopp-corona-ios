//
//  SavedIDsCoordinator.swift
//  CoronaContact
//

import UIKit

final class SavedIDsCoordinator: Coordinator {

    // MARK: - Properties

    private lazy var rootViewController: SavedIDsViewController = {
        let controller = SavedIDsViewController.instantiate()
        controller.viewModel = SavedIDsViewModel(self)
        return controller
    }()

    private weak var deletionSuccessViewController: SavedIDsDeletionSuccessViewController?

    let navigationController: UINavigationController

    // MARK: - Lifecycle

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Coordination

    override func start() {
        navigationController.pushViewController(rootViewController, animated: true)
    }

    /// Shows a `SavedIDsDeletionSuccessViewController` as feedback after keys have been deleted.
    func didDeleteKeys() {
        let controller = makeDeletionSuccessViewController()
        controller.modalPresentationStyle = .fullScreen
        self.deletionSuccessViewController = controller
        rootViewController.present(controller, animated: true, completion: nil)
    }

    /// Dismisses the `confirmationViewController` and closes the menu to land back on the main screen
    func deletionConfirmationAcknowledged() {
        deletionSuccessViewController?.dismiss(animated: true, completion: nil)

        guard let menuCoordinator = ancestors.firstOfType(StartMenuCoordinator.self) else {
            assertionFailure("Could not find the start menu coordinator.")
            return
        }
        menuCoordinator.closeMenu()
    }

    // MARK: - Housekeeping

    override func finish(animated: Bool = false) {
        parentCoordinator?.didFinish(self)
    }

    // MARK: - Private

    private func makeDeletionSuccessViewController() -> SavedIDsDeletionSuccessViewController {
        let controller = SavedIDsDeletionSuccessViewController.instantiate()
        controller.viewModel = SavedIDsDeletionConfirmationViewModel(self)
        return controller
    }
}
