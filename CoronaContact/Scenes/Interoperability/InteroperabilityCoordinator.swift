//
//  InteroperabilityCoordinator.swift
//  CoronaContact
//

import UIKit

final class InteroperabilityCoordinator: Coordinator {
    
    private lazy var rootViewController: UINavigationController = {
        let viewController = InteroperabilityViewController.instantiate(with: InteroperabilityViewModel(coordinator: self))
        let controller = UINavigationController(rootViewController: viewController)
        return controller
    }()
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() {
        self.rootViewController.modalPresentationStyle = .fullScreen
        self.navigationController.present(rootViewController, animated: true, completion: nil)
    }
        
    override func finish(animated: Bool = false) {
        
        self.rootViewController.dismiss(animated: animated) {
            self.parentCoordinator?.didFinish(self)
        }
    }
}
