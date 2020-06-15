//
//  ExposureManager.swift
//  CoronaContact
//

import ExposureNotification
import Foundation
import Resolver

typealias Completion<T> = (Result<T, Error>) -> Void

@available(iOS 13.5, *)
class ExposureManager {
    static let authorizationStatusChangedNotification = Notification.Name("ExposureManagerAuthorizationStatusChanged")
    static let notificationStatusChangedNotification = Notification.Name("ExposureManagerNotificationStatusChanged")

    @Injected private var localStorage: LocalStorage
    @Injected var batchDownloadScheduler: BatchDownloadScheduler
    private let manager = ENManager()
    private let log = ContextLogger(context: .exposure)
    private var kvoToken: NSKeyValueObservation?
    var exposureNotificationStatus: ENStatus {
        manager.exposureNotificationStatus
    }

    public var authorizationStatus: ENAuthorizationStatus {
        ENManager.authorizationStatus
    }

    init() {
        manager.activate { _ in

            self.kvoToken = self.manager.observe(\ENManager.exposureNotificationStatus, options: .new) { _, _ in
                NotificationCenter.default.post(name: ExposureManager.notificationStatusChangedNotification, object: nil)
            }

            if ENManager.authorizationStatus == .authorized,
                !self.manager.exposureNotificationEnabled,
                !self.localStorage.backgroundHandshakeDisabled {
                self.manager.setExposureNotificationEnabled(true) { error in
                    NotificationCenter.default.post(name: ExposureManager.authorizationStatusChangedNotification, object: nil)
                    self.log.info("exposure notification enabled error:\(String(describing: error))")
                    // No error handling for attempts to enable on launch
                }
            }
        }
    }

    deinit {
        kvoToken?.invalidate()
        manager.invalidate()
    }

    func detectExposures(completion: @escaping (Bool) -> Void) -> Progress {
        let progress = Progress()
        completion(true)
        return progress
    }

    func enableExposureNotifications(_ enabled: Bool, completion: ((Error?) -> Void)? = nil) {
        localStorage.backgroundHandshakeDisabled = !enabled

        log.debug("enableExposureNotifications \(enabled)")
        manager.setExposureNotificationEnabled(enabled) { error in
            NotificationCenter.default.post(name: ExposureManager.authorizationStatusChangedNotification, object: nil)
            self.log.info("setExposureNotificationEnabled \(enabled) error:\(String(describing: error))")
            if error == nil, enabled {
                self.batchDownloadScheduler.scheduleBackgroundTaskIfNeeded()
            }
            completion?(error)
        }
    }

    func getDiagnosisKeys(completion: @escaping (Result<[ENTemporaryExposureKey], Error>) -> Void) {
        #if DEBUG
            let keyFunction = manager.getTestDiagnosisKeys
        #else
            let keyFunction = manager.getDiagnosisKeys
        #endif
        keyFunction { temporaryExposureKeys, error in
            if let error = error {
                completion(.failure(error))
            } else {
                self.log.debug("keys: \(temporaryExposureKeys!)")
                completion(.success(temporaryExposureKeys ?? []))
            }
        }
    }

    func getKeysForUpload(from startDate: Date,
                          untilIncluding endDate: Date,
                          diagnosisType: DiagnosisType,
                          completion: @escaping Completion<[TemporaryExposureKey]>) {
        getDiagnosisKeys { result in
            switch result {
            case let .success(enTemporaryExposureKeys):
                do {
                    let startTime = startDate.startOfDayUTC().timeIntervalSince1970
                    let endTime = endDate.addDays(1)!.startOfDayUTC().timeIntervalSince1970
                    let filteredKeys = enTemporaryExposureKeys.filter { key in
                        let timeStamp = key.rollingStartNumber.timeInterval
                        return startTime <= timeStamp && timeStamp < endTime
                    }

                    let intervals = filteredKeys.map(\.rollingStartNumber)
                    let passwords = try TracingKeyPassword.getPasswordsFor(intervals: intervals)

                    let temporaryExposureKeys = filteredKeys.map { key in
                        TemporaryExposureKey(temporaryExposureKey: key, password: passwords[key.rollingStartNumber])
                    }
                    #if DEBUG || STAGE
                        self.log.debug("Uploading Keys: \(diagnosisType) \(startDate) - \(endDate)")
                        temporaryExposureKeys.forEach { key in
                            self.log.debug("Key: \(key.intervalNumber) \(key.intervalNumber.date)")
                        }
                    #endif

                    completion(.success(temporaryExposureKeys))
                } catch {
                    completion(.failure(error))
                }

            case let .failure(error):
                LoggingService.error("Couldn't get diagnosis keys from the exposure manager: \(error)", context: .exposure)
                completion(.failure(error))
            }
        }
    }
}

#warning("DELETE ME AFTER MERGING OTHER BRANCH INCLUDING THIS")
extension ENIntervalNumber {
    var timeInterval: TimeInterval {
        Double(self) * 60 * 10
    }

    var date: Date {
        Date(timeIntervalSince1970: timeInterval)
    }
}
