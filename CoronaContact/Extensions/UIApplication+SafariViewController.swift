//
//  UIApplication+SafariViewController.swift
//  CoronaContact
//

import UIKit
import SafariServices

extension UIApplication {

    func openURLinSafariVC(_ url: URL, from viewController: UIViewController? = nil) {
        let safariVC = SFSafariViewController(url: url)
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let viewController = viewController ?? appDelegate.window?.rootViewController
            if let presentingViewController = viewController {
                presentingViewController.present(safariVC, animated: true)
            }
        }
    }
}
