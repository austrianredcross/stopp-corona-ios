//
//  MissingPermissionsCoordinator.swift
//  CoronaContact
//

import UIKit

final class MissingPermissionsCoordinator: Coordinator {
    enum PermissionType {
        case bluetooth
        case backgroundAppRefresh
        case exposureFramework

        var viewController: MissingPermissionsViewController {
            switch self {
            case .bluetooth:
                return .bluetooth
            case .backgroundAppRefresh:
                return .backgroundAppRefresh
            case .exposureFramework:
                return .exposureFramework
            }
        }
    }

    let rootViewController: MissingPermissionsViewController
    var navigationController: UINavigationController

    init(type: PermissionType, navigationController: UINavigationController) {
        rootViewController = type.viewController
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
