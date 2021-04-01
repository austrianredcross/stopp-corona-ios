//
//  DiaryFaqCoordinator.swift
//  CoronaContact
//
import UIKit

class DiaryFaqCoordinator: Coordinator {
    var navigationController: UINavigationController

    lazy var rootViewController: DiaryFaqViewController = {
        
        return DiaryFaqViewController.instantiate(with: DiaryFaqViewModel(coordinator: self))
    }()

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        navigationController.pushViewController(rootViewController, animated: true)
    }

    override func finish(animated: Bool = false) {
        parentCoordinator?.didFinish(self)
    }
}
