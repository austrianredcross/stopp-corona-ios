//
//  QuarantineTimeController.swift
//  CoronaContact
//

import Foundation
import Resolver

struct QuarantineTimeConfiguration {
    /// number of quarantine days if contact was diagnosed
    let redWarning: Int
    /// number of quarantine days if contact had symptoms
    let yellowWarning: Int
    /// number of quarantine days for users with symptoms but no diagnosis yet
    let probablySick: Int
    /// number of quarantine days for users with positive diagnosis
    let attestedSick: Int

    init(redWarning: Int = 14, yellowWarning: Int = 7, probablySick: Int = 7, attestedSick: Int = Int.max) {
        self.redWarning = redWarning
        self.yellowWarning = yellowWarning
        self.probablySick = probablySick
        self.attestedSick = attestedSick
    }

    init(configuration: Configuration) {
        // Convert hours to days
        self.init(
            redWarning: configuration.redWarningQuarantine / 24,
            yellowWarning: configuration.yellowWarningQuarantine / 24,
            probablySick: configuration.selfDiagnosedQuarantine / 24
        )
    }
}

class QuarantineTimeController {
    enum QuarantineType {
        case red
        case yellow
        case selfDiagnosed
    }

    struct QuarantineEnd {
        let type: QuarantineType
        let date: Date

        var numberOfDays: Int? {
            guard let numberOfdays = Date().days(until: date) else {
                return nil
            }

            return numberOfdays
        }
    }

    enum QuarantineStatus {
        case unknown
        case cleared
        case completed(QuarantineEnd)
        case inProgress(QuarantineEnd)
        /// End of quarantine needs to be determined by health professionals if tested positively
        case inProgressIndefinitely

        var isUnknown: Bool {
            if case .unknown = self {
                return true
            }

            return false
        }

        var isCleared: Bool {
            if case .cleared = self {
                return true
            }

            return false
        }

        var isCompleted: Bool {
            if case .completed = self {
                return true
            }

            return false
        }

        var isInProgress: Bool {
            if case .inProgress = self {
                return true
            }

            return false
        }

        var isInProgressIndefinitely: Bool {
            if case .inProgressIndefinitely = self {
                return true
            }

            return false
        }

        var date: Date? {
            switch self {
            case let .completed(end), let .inProgress(end):
                return end.date
            default:
                return nil
            }
        }

        var numberOfDays: Int? {
            switch self {
            case let .completed(end), let .inProgress(end):
                return end.numberOfDays
            default:
                return nil
            }
        }
    }

    @Injected private var databaseService: DatabaseService
    @Injected private var notificationService: NotificationService
    @Injected private var localStorage: LocalStorage

    private var observers = [NSObjectProtocol]()
    private let timeConfiguration: QuarantineTimeConfiguration
    private let calendar = Calendar.current
    private var dateGenerator: () -> Date = {
        Date()
    }

    private var lastRefreshAt: Date?

    private let subscriber: (QuarantineStatus) -> Void

    init(timeConfiguration: QuarantineTimeConfiguration = QuarantineTimeConfiguration(),
         databaseService: DatabaseService? = nil,
         dateGenerator: (() -> Date)? = nil,
         subscriber: @escaping (QuarantineStatus) -> Void) {
        self.timeConfiguration = timeConfiguration
        self.subscriber = subscriber
        self.dateGenerator = dateGenerator ?? self.dateGenerator
        self.databaseService = databaseService ?? self.databaseService

        registerObservers()
        refresh()
    }

    private func registerObservers() {
        observers.append(localStorage.$attestedSicknessAt.addObserver(using: refresh))
        observers.append(localStorage.$isProbablySickAt.addObserver(using: refresh))
    }

    public func refreshIfNecessary() {
        guard let lastRefreshAt = lastRefreshAt, !calendar.isDateInToday(lastRefreshAt) else {
            return
        }

        refresh()
    }

    @objc
    private func refresh() {
        quarantineStatus { [weak self] quarantineStatus in
            self?.lastRefreshAt = self?.dateGenerator()
            self?.setupRevocation(for: quarantineStatus)
            self?.subscriber(quarantineStatus)
            self?.scheduleNotification(for: quarantineStatus)
        }
    }

    func quarantineStatus(completion: @escaping (QuarantineStatus) -> Void) {
        if localStorage.hasAttestedSickness {
            return completion(.inProgressIndefinitely)
        }

        // TODO: add new calculation
    }

    private func scheduleNotification(for quarantineStatus: QuarantineStatus) {
        guard let date = quarantineStatus.date else {
            return
        }

        notificationService.showQuarantineCompletedNotification(endOfQuarantine: date)
    }

    private func setupRevocation(for quarantineStatus: QuarantineStatus) {
        switch quarantineStatus {
        case let .completed(end) where end.type == .selfDiagnosed:
            localStorage.completedVoluntaryQuarantine = true
            localStorage.isProbablySickAt = nil
        case .completed:
            localStorage.completedRequiredQuarantine = true
        case .cleared:
            localStorage.allClearQuarantine = true
        default:
            break
        }
    }

    private func addDays(_ days: Int, to date: Date) -> Date {
        calendar.date(byAdding: .day, value: days, to: date)!
    }

    deinit {
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
