//
//  BatchDownload+Injection.swift
//  CoronaContact
//

import Foundation
import Resolver

extension Resolver {
    static func registerBatchDownloadServices() {
        register { BatchDownloadService() }.scope(application)
        register { BatchDownloadScheduler() }.scope(application)
        register { AppStartBatchController() }
    }
}
