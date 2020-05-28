//
//  Appdelegate+Injection.swift
//  CoronaContact
//

import Foundation

import Resolver

extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        registerLoggingeService()
        registerMessageUpdateServices()
        registerConfigurationServices()
        registerDatabaseServices()
        registerCryptoServices()
        registerNetworkServices()
        registerSelfTestingDependencies()
        registerRevocationDependencies()
        registerRevokeSicknessDependencies()
        registerNotificationServices()
        registerAppUpdateServices()
        registerHealthRepository()
        registerLocalStorageServices()
        registerSicknessCertificateDependencies()
        registerExposureServices()
    }
}
