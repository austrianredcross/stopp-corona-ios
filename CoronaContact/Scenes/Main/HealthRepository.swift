//
//  HealthRepository.swift
//  CoronaContact
//

import Foundation
import Resolver

extension Resolver {
    public static func registerHealthRepository() {
        register { () -> HealthRepository in
            let configurationService: ConfigurationService = resolve()
            let timeConfiguration = QuarantineTimeConfiguration(configuration: configurationService.currentConfig!)
            return HealthRepository(timeConfiguration: timeConfiguration)
        }.scope(application)
    }
}

class HealthRepository {
    private var quarantineTimeController: QuarantineTimeController!
    @Injected private var dba: DatabaseService
    @Injected private var configService: ConfigurationService

    @Observable var userHealthStatus: UserHealthStatus = .isHealthy
    @Observable var revocationStatus: RevocationStatus?
    @Observable var contactHealthStatus: ContactHealthStatus?
    @Observable var numberOfContacts = 0
    @Observable var infectionWarnings: [InfectionWarning] = []

    var subscriptions = Set<AnySubscription>()

    init(timeConfiguration: QuarantineTimeConfiguration) {
        quarantineTimeController = QuarantineTimeController(timeConfiguration: timeConfiguration) { [weak self] quarantineUpdate in
            self?.handle(quarantineUpdate)
        }

        $userHealthStatus.subscribe { [weak self] healthStatus in
            switch healthStatus {
            case .hasAttestedSickness, .isProbablySick, .isUnderSelfMonitoring:
                self?.removeRevocationStatus()
            case .isHealthy:
                break
            }
        }.add(to: &subscriptions)

        $contactHealthStatus.subscribe { [weak self] healthStatus in
            if healthStatus != nil {
                self?.removeRevocationStatus()
            }
        }.add(to: &subscriptions)
    }

    var isProbablySick: Bool {
        if case .isProbablySick = userHealthStatus {
            return true
        }

        return false
    }
    var hasAttestedSickness: Bool {
        if case .hasAttestedSickness = userHealthStatus {
            return true
        }

        return false
    }

    func refresh() {
        quarantineTimeController.refreshIfNecessary()
    }

    func removeRevocationStatus() {
        revocationStatus?.clear()
        revocationStatus = nil
    }

    private func handle(_ quarantineStatus: QuarantineTimeController.QuarantineStatus) {
        revocationStatus = RevocationStatus()

        if case .completed = quarantineStatus {
            userHealthStatus = .isHealthy
            contactHealthStatus = nil
            return
        }

        userHealthStatus = UserHealthStatus(quarantineDays: quarantineStatus.numberOfDays)

        /* TODO: redo new system
        dba.getIncomingInfectionWarnings { [weak self] infectionWarnings in
            self?.contactHealthStatus = ContactHealthStatus(
                    basedOn: infectionWarnings,
                    quarantineDays: quarantineStatus.numberOfDays
            )
        }
        */
    }

}
