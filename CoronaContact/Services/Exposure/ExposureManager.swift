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

@available(iOS 13.4, *)
class ExposureManager {
    @Injected private var localStorage: LocalStorage
    private let manager = ENManager()
    private let log = ContextLogger(context: .exposure)
    var kvoToken: NSKeyValueObservation?
    var exposureNotificationStatus: ENStatus { manager.exposureNotificationStatus }

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

    func enableExposureNotifications(_ enabled: Bool) {
        localStorage.backgroundHandshakeDisabled = !enabled

        log.debug("enableExposureNotifications \(enabled)")
        manager.setExposureNotificationEnabled(enabled) { error in
            NotificationCenter.default.post(name: .exposureManagerAuthorizationStatusChanged, object: nil)
            self.log.info("setExposureNotificationEnabled \(enabled) error:\(String(describing: error))")
            if let error = error as? ENError, error.code == .notAuthorized {
                // TODO: error handling
            }
        }
    }
}
