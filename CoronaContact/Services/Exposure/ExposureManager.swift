//
//  ExposureManager.swift
//  CoronaContact
//

import ExposureNotification
import Foundation
import Resolver

extension Notification.Name {
    static let exposureManagerAuthorizationStatusChanged = Notification.Name("ExposureManagerAuthorizationStatusChangedNotification")
    static let exposureManagerNotificationStatusChanged = Notification.Name("ExposureManagerNotificationStatusChangedNotification")
}

@available(iOS 13.5, *)
class ExposureManager {
    @Injected private var localStorage: LocalStorage
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
                NotificationCenter.default.post(name: .exposureManagerNotificationStatusChanged, object: nil)
            }

            if ENManager.authorizationStatus == .authorized,
                !self.manager.exposureNotificationEnabled,
                !self.localStorage.backgroundHandshakeDisabled {
                self.manager.setExposureNotificationEnabled(true) { error in
                    NotificationCenter.default.post(name: .exposureManagerAuthorizationStatusChanged, object: nil)
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
            NotificationCenter.default.post(name: .exposureManagerAuthorizationStatusChanged, object: nil)
            self.log.info("setExposureNotificationEnabled \(enabled) error:\(String(describing: error))")
            if error == nil, enabled, let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.scheduleBackgroundTaskIfNeeded()
            }
            completion?(error)
        }
    }

    func getDiagnosisKeys(completion: @escaping (Result<[ENTemporaryExposureKey], Error>) -> Void) {
        manager.getDiagnosisKeys { temporaryExposureKeys, error in
            if let error = error {
                completion(.failure(error))
            } else {
                self.log.debug("keys: \(temporaryExposureKeys!)")
                completion(.success(temporaryExposureKeys ?? []))
            }
        }
    }

    // Includes today's key, requires com.apple.developer.exposure-notification-test entitlement
    func getTestDiagnosisKeys(completion: @escaping (Result<[ENTemporaryExposureKey], Error>) -> Void) {
        manager.getTestDiagnosisKeys { temporaryExposureKeys, error in
            if let error = error {
                completion(.failure(error))
            } else {
                self.log.debug("keys: \(temporaryExposureKeys!)")
                completion(.success(temporaryExposureKeys ?? []))
            }
        }
    }
}
