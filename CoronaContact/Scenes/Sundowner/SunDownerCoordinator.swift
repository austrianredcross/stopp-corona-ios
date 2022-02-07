//
//  SundownerCoordinator.swift
//  CoronaContact
//

import UIKit

final class SunDownerCoordinator: Coordinator, ErrorPresentableCoordinator {
    
    lazy var rootViewController: UINavigationController = {
        let viewController = SunDownerViewController.instantiate(with: SunDownerViewModel(with: self))
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
    
    func showNewsletter() {
        guard let url = URL(string: "sunDowner_newsletter_link".localized) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
