//
//  ApplicationCoordinator.swift
//  CoronaContact
//

import UIKit
import Resolver

class ApplicationCoordinator: Coordinator {
    let window: UIWindow?
    private weak var mainCoordinator: MainCoordinator?

    enum ExternalCalledRoutes {
        case selfTest
    }

    lazy var rootViewController: UINavigationController = {
        UINavigationController()
    }()

    init(window: UIWindow?) {
        self.window = window
        super.init()
    }

    func gotoMainScreen() {
        let child = MainCoordinator(navigationController: rootViewController)
        addChildCoordinator(child)
        mainCoordinator = child
        child.start()
    }

    override func start() {
        guard let window = window else {
            return
        }
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()

        gotoMainScreen()
    }

    func startSelfTestExternally() {
        if let presented = rootViewController.presentedViewController {
            presented.dismiss(animated: false)
        }
        rootViewController.popToRootViewController(animated: false)
        mainCoordinator?.selfTesting()
    }
}
