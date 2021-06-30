//
//  AppDelegate+Injection.swift
//  CoronaContact
//

import Foundation
import Resolver

extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        registerLoggingeService()
        registerConfigurationServices()
        registerDatabaseServices()
        registerNetworkServices()
        registerSelfTestingDependencies()
        registerRevocationDependencies()
        registerAGESDependencies()
        registerRevokeSicknessDependencies()
        registerNotificationServices()
        registerAppUpdateServices()
        registerHealthRepository()
        registerLocalStorageServices()
        registerSicknessCertificateDependencies()
        registerBatchDownloadServices()
        registerRiskCalculationController()
        registerExposureServices()
        registerCoreDataService()
    }
}
