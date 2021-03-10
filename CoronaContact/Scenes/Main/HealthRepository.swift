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
    @Injected private var notificationService: NotificationService
    @Injected private var dba: DatabaseService
    @Injected private var localStorage: LocalStorage
    @Injected private var configService: ConfigurationService

    @Observable var userHealthStatus: UserHealthStatus = .isHealthy
    @Observable var revocationStatus: RevocationStatus?
    @Observable var contactHealthStatus: ContactHealthStatus?
    @Observable var infectionWarnings: [InfectionWarning] = []

    var subscriptions = Set<AnySubscription>()

    init(timeConfiguration: QuarantineTimeConfiguration) {
        quarantineTimeController = QuarantineTimeController(timeConfiguration: timeConfiguration) { [weak self] quarantineStatus in
            self?.handle(quarantineStatus)
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
            if healthStatus != nil && !(self?.localStorage.allClearQuarantine ?? false) {
                self?.removeRevocationStatus()
                self?.notificationService.addSelfTestReminderNotificationIn()
            } else {
                self?.notificationService.removeSelfTestReminderNotification()
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

        contactHealthStatus = ContactHealthStatus(quarantineDays: quarantineStatus.numberOfDays)
    }

    func setProbablySick(from date: Date) {
        localStorage.isProbablySickAt = date
        localStorage.hasSymptomsOrPositiveAttestAt = nil
    }

    func setProvenSick(from date: Date) {
        localStorage.attestedSicknessAt = date
        localStorage.hasSymptomsOrPositiveAttestAt = nil
    }

    func revokeProbablySick() {
        localStorage.revokeProbablySickness = true
        localStorage.isProbablySickAt = nil
        localStorage.missingUploadedKeysAt = nil
    }

    func revokeProvenSickness() {
        localStorage.finishProvenSicknessQuarantine = true
        localStorage.attestedSicknessAt = nil
        localStorage.missingUploadedKeysAt = nil
    }
}
