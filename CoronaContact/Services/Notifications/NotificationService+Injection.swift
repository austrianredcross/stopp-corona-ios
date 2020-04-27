//
//  NotificationService+Injection.swift
//  CoronaContact
//

import Foundation
import Resolver

extension Resolver {
    public static func registerNotificationServices() {
        register { NotificationService() }.scope(application)
    }
}
