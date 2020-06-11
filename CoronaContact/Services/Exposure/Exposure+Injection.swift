//
//  Exposure+Injection.swift
//  CoronaContact
//

import Foundation
import Resolver

@available(iOS 13.5, *)
extension Resolver {
    public static func registerExposureServices() {
        register { ExposureManager() }
            .resolveProperties { _, exposureManager in
                exposureManager.batchDownloadScheduler.exposureManager = exposureManager
            }.scope(application)
    }
}
