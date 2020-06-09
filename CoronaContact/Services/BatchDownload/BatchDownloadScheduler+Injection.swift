//
//  BatchDownloadScheduler+Injection.swift
//  CoronaContact
//

import Foundation
import Resolver

extension Resolver {
    static func registerBatchDownloadServices() {
        register { BatchDownloadScheduler() }.scope(application)
    }
}
