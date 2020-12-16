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
        case none
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
         subscriber: @escaping (QuarantineStatus) -> Void)
    {
        self.timeConfiguration = timeConfiguration
        self.subscriber = subscriber
        self.dateGenerator = dateGenerator ?? self.dateGenerator
        self.databaseService = databaseService ?? self.databaseService

        registerObservers()
        refresh()
    }

    static func quarantineTimeCalculation(riskResult: RiskCalculationResult) {
        var lastRedContact: Date?
        var lastYellowContact: Date?
        let localStorage: LocalStorage = Resolver.resolve()

        for (date, riskType) in riskResult {
            if riskType == .yellow, lastYellowContact == nil || lastYellowContact! < date {
                lastYellowContact = date
            }
            if riskType == .red, lastRedContact == nil || lastRedContact! < date {
                lastRedContact = date
            }
        }
        localStorage.lastRedContact = lastRedContact
        localStorage.lastYellowContact = lastYellowContact
    }

    private func registerObservers() {
        observers.append(localStorage.$isUnderSelfMonitoring.addObserver(using: refresh))
        observers.append(localStorage.$attestedSicknessAt.addObserver(using: refresh))
        observers.append(localStorage.$isProbablySickAt.addObserver(using: refresh))
        observers.append(localStorage.$lastYellowContact.addObserver(using: refresh))
        observers.append(localStorage.$lastRedContact.addObserver(using: refresh))
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
            if let attestedSicknessAt = localStorage.attestedSicknessAt {
                let endOfQuarantine = QuarantineEnd(
                    type: .selfDiagnosed,
                    date: addDays(timeConfiguration.redWarning, to: attestedSicknessAt))
                
                return completion(.inProgress(endOfQuarantine))
            }
            
            return completion(.inProgressIndefinitely)
        }

        var endOfQuarantines = [QuarantineEnd]()

        if let lastYellowContact = localStorage.lastYellowContact {
            let endOfQuarantine = QuarantineEnd(
                type: .yellow,
                date: addDays(timeConfiguration.yellowWarning, to: lastYellowContact)
            )
            endOfQuarantines.append(endOfQuarantine)
        }

        if let lastRedContact = localStorage.lastRedContact {
            let endOfQuarantine = QuarantineEnd(
                type: .red,
                date: addDays(timeConfiguration.redWarning, to: lastRedContact)
            )
            endOfQuarantines.append(endOfQuarantine)
        }

        if let isProbablySickAt = localStorage.isProbablySickAt {
            let endOfQuarantine = QuarantineEnd(
                type: .selfDiagnosed,
                date: addDays(timeConfiguration.probablySick, to: isProbablySickAt)
            )
            endOfQuarantines.append(endOfQuarantine)
        }

        guard let quarantineEndingLast = endOfQuarantines
            .sorted(by: { $0.date < $1.date })
            .last
        else {
            let status: QuarantineStatus = localStorage.wasQuarantined ? .cleared : .none
            completion(status)
            return
        }

        localStorage.wasQuarantined = true
        if let daysUntilEnd = quarantineEndingLast.numberOfDays, daysUntilEnd <= 0 {
            completion(.completed(quarantineEndingLast))
            return
        }

        completion(.inProgress(quarantineEndingLast))
    }

    private func scheduleNotification(for quarantineStatus: QuarantineStatus) {
        if quarantineStatus.isCleared {
            notificationService.showQuarantineCompletedNotification(endOfQuarantine: nil)
        } else if let date = quarantineStatus.date {
            notificationService.showQuarantineCompletedNotification(endOfQuarantine: date)
        }
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
