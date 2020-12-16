//
//  ApplicationCoordinator.swift
//  CoronaContact
//

import Resolver
import UIKit

class ApplicationCoordinator: Coordinator {
    let window: UIWindow?
    private weak var mainCoordinator: MainCoordinator?

    enum ExternalCalledRoutes {
        case selfTest
    }

    lazy var rootViewController: UINavigationController = {
        #if DEBUG || STAGE
            let dvc = DebugNavigationController()
            dvc.coordinator = self
            return dvc
        #else
            return UINavigationController()
        #endif
    }()

    func debugView() {
        let child = DebugCoordinator(navigationController: rootViewController)
        addChildCoordinator(child)
        child.start()
    }

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
        mainCoordinator?.selfTesting(updateKeys: false)
    }
    
    func openWebView(websiteType: Website) {
        
        guard let presented = rootViewController.presentedViewController as? UINavigationController else { return }
        
        let child = StartMenuSimpleWebViewCoordinator(navigationController: presented)
        addChildCoordinator(child)
        child.start(present: true)
        child.rootViewController.viewModel?.website = websiteType
    }
    
    func openFAQ() {
        guard let presented = rootViewController.presentedViewController as? UINavigationController else { return }
        ExternalWebsite.faq.openInSafariVC(from: presented)
    }
}
