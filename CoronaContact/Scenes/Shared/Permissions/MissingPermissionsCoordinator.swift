//
//  MissingPermissionsCoordinator.swift
//  CoronaContact
//

import UIKit

final class MissingPermissionsCoordinator: Coordinator {

    enum PermissionType {
        case bluetooth
        case backgroundAppRefresh

        var viewController: MissingPermissionsViewController {
            switch self {
            case .bluetooth:
                return .bluetooth
            case .backgroundAppRefresh:
                return .backgroundAppRefresh
            }
        }
    }

    let rootViewController: MissingPermissionsViewController
    var navigationController: UINavigationController

    init(type: PermissionType, navigationController: UINavigationController) {
        self.rootViewController = type.viewController
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = MissingPermissionsViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }

    override func finish(animated: Bool = false) {
        navigationController.popViewController(animated: animated)
        parentCoordinator?.didFinish(self)
    }
}
