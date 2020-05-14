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
        registerP2pkitServices()
        registerNearbyServices()
        registerNetworkServices()
        registerSelfTestingDependencies()
        registerSicknessCertificateDependencies()
        registerRevocationDependencies()
        registerRevokeSicknessDependencies()
        registerNotificationServices()
        registerAppUpdateServices()
        registerHealthRepository()
    }
}
