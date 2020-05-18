//
//  ExposureManager.swift
//  CoronaContact
//

import Foundation
import ExposureNotification


@available(iOS 13.4, *)
class ExposureManager {
    let manager = ENManager()

    init() {
        manager.activate { _ in
            // Ensure exposure notifications are enabled if the app is authorized. The app
            // could get into a state where it is authorized, but exposure
            // notifications are not enabled,  if the user initially denied Exposure Notifications
            // during onboarding, but then flipped on the "COVID-19 Exposure Notifications" switch
            // in Settings.
            if ENManager.authorizationStatus == .authorized && !self.manager.exposureNotificationEnabled {
                self.manager.setExposureNotificationEnabled(true) { _ in
                    // No error handling for attempts to enable on launch
                }
            }
        }
    }

    deinit {
        manager.invalidate()
    }
}
