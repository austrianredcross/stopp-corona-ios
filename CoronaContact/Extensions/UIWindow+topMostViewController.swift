//
//  UIWindow+topMostViewController.swift
//  CoronaContact
//

import UIKit

extension UIWindow {
    var topMostViewController: UIViewController? {
        if var topController = rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }

            // topController should now be your topmost view controller
            return topController
        }
        return nil
    }
}
