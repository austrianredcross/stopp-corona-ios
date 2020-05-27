//
//  UIWindow+key.swift
//  CoronaContact
//

import UIKit

extension UIWindow {
    static var key: UIWindow? {
        UIApplication.shared.windows.first { $0.isKeyWindow }
    }
}
