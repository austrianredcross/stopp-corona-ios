//
//  NotificationService.swift
//  CoronaContact
//

import Resolver
import UIKit
import UserNotifications

struct NotificationServiceKeys {
    static let selfTestPush = "selfTestPush"
    static let quarantineCompleted = "quarantineCompleted"
    static let uploadMissingDay = "uploadMissingDay"
    static let hasBeenVisibleSunDowner = "hasBeenVisibleSunDowner"
    static let sundownerIsToday = "sundownerIsToday"
}

class NotificationService: NSObject {
    @Injected private var localStorage: LocalStorage
    private let notificationCenter = UNUserNotificationCenter.current()
    private let log = ContextLogger(context: .notifications)
    private var observers = [NSObjectProtocol]()

    private lazy var dateComponents: (_ date: Date) -> DateComponents = { date in
        Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
    }

    override init() {
        super.init()
        observers.append(localStorage.$missingUploadedKeysAt.addObserver(using: registerMissingKeysReminder))
        #if LOGGING
            notificationCenter.getPendingNotificationRequests { requests in
                self.log.debug("scheduled notifications: \(requests)")
            }
        #endif
    }

    func dismissAllNotifications() {
        notificationCenter.removeAllDeliveredNotifications()
    }
    
    func showSundownerNotification() {

        log.info("Show Sundowner Notification")
        
        if !localStorage.hasBeenVisibleSunDowner && !localStorage.sundownerForceUpdatelocalNotificationHasBeenVisible {
            localStorage.sundownerForceUpdatelocalNotificationHasBeenVisible = true
            
            showNotification(
                identifier: NotificationServiceKeys.hasBeenVisibleSunDowner,
                title: "local_notification_sundowner_title".localized,
                body: String(format: "local_notification_sundowner_forced_update".localized, Date().sundDownerDate.shortDayShortMonthLongYear),
                at: Date()
            )
            log.info("Sundowner Notification was displayed because the hasBeenVisibleSunDowner is false")
        } else if Date().sundDownerDate.isToday, !localStorage.sundownerIsTodaylocalNotificationHasBeenVisible {
            localStorage.sundownerIsTodaylocalNotificationHasBeenVisible = true

            showNotification(
                identifier: NotificationServiceKeys.sundownerIsToday,
                title: "local_notification_sundowner_title".localized,
                body: "local_notification_sundowner_last_day_notification".localized,
                at: Date().sundDownerDate
            )
            log.info("Sundowner Notification was displayed because the sundDownerDate isToday")
        } else {
            log.info("Sundowner Date :\(Date().sundDownerDate.isToday)")
            log.info("hasBeenVisibleSunDowner :\(localStorage.hasBeenVisibleSunDowner)")
            log.error("Sundowner Notification was not displayed")
        }
    }

    func registerMissingKeysReminder() {
        let notificationTime = localStorage.missingUploadedKeysAt?.startOfDayUTC().addDays(1)

        if let notificationTime = notificationTime, notificationTime > Date() {
            showNotification(
                identifier: NotificationServiceKeys.uploadMissingDay,
                title: "upload_missing_keys_notification_title".localized,
                body: "upload_missing_keys_notification_message".localized,
                at: notificationTime
            )
            log.info("scheduling reminder to upload keys from report day at \(notificationTime)")
        } else {
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [NotificationServiceKeys.uploadMissingDay])
            log.debug("removing possible reminder to upload keys from report day")
        }
    }

    func askForPermissions() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            if error != nil {
                self?.log.error("there was an \(error.debugDescription) when registering notifications, it was granted: \(granted)")
            }
        }
    }

    func showSuspectedSickContactNotification(_ warning: InfectionWarning) {
        let title = "local_notification_suspected_sick_contact_headline".localized
        let body = "local_notification_suspected_sick_contact_message".localized
        showNotification(title: title, body: body)
    }

    func showCertifiedSickContactNotification(_ warning: InfectionWarning) {
        let title = "local_notification_sick_contact_headline".localized
        let body = "local_notification_sick_contact_message".localized
        showNotification(title: title, body: body)
    }

    func showQuarantineCompletedNotification(endOfQuarantine: Date? = nil) {
        let title = "local_notification_quarantine_end_headline".localized
        let body = "local_notification_quarantine_end_message".localized

        notificationCenter.getPendingNotificationRequests { [weak self] requests in
            let isAlreadyScheduled = requests.contains { $0.identifier == NotificationServiceKeys.quarantineCompleted }

            if let endOfQuarantine = endOfQuarantine, !endOfQuarantine.isToday {
                self?.showNotification(
                    identifier: NotificationServiceKeys.quarantineCompleted,
                    title: title,
                    body: body,
                    at: endOfQuarantine
                )
            } else if isAlreadyScheduled {
                self?.showNotification(
                    identifier: NotificationServiceKeys.quarantineCompleted,
                    title: title,
                    body: body
                )
            }
        }
    }

    func showTestNotifications() {
        createUNNotificationRequest(forSeconds: 10)

        let titleRed = "TEST: \("local_notification_sick_contact_headline".localized))"
        let bodyRed = "local_notification_sick_contact_message".localized
        showNotification(title: titleRed, body: bodyRed, delay: 5)

        let titleYellow = "TEST: \("local_notification_suspected_sick_contact_headline".localized)"
        let bodyYellow = "local_notification_suspected_sick_contact_message".localized
        showNotification(title: titleYellow, body: bodyYellow, delay: 5)
    }

    func showNotification(identifier: String = UUID().uuidString, title: String, body: String, delay: Int = 0) {
        let content = UNMutableNotificationContent()

        content.title = title
        content.body = body

        content.categoryIdentifier = "alarm"

        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        let request = UNNotificationRequest(identifier: identifier,
                                            content: content,
                                            trigger: trigger)

        notificationCenter.add(request)
    }

    func showNotification(identifier: String = UUID().uuidString, title: String, body: String, at date: Date) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])

        let content = UNMutableNotificationContent()

        content.title = title
        content.body = body
        content.categoryIdentifier = "alarm"
        content.sound = UNNotificationSound.default

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents(date), repeats: false)
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content,
                                            trigger: trigger)

        notificationCenter.add(request)
    }

    func addSelfTestReminderNotificationIn() {
        removeSelfTestReminderNotification()

        // Create AM Time
        createUNNotificationRequest(forHour: 10)
        // Create PM Time
        createUNNotificationRequest(forHour: 16)
    }
    
    private func createUNNotificationRequest(forHour hour: Int? = nil, forSeconds seconds: Int = 10) {
        
        let content = UNMutableNotificationContent()
        content.title = "self_test_push_reminder".localized

        content.categoryIdentifier = "alarm"
        content.sound = UNNotificationSound.default
        content.userInfo = ["type": NotificationServiceKeys.selfTestPush]
        
        var request: UNNotificationRequest
        
        if let hour = hour {
            var datComp = DateComponents()

            datComp.hour = hour
            datComp.minute = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: datComp, repeats: true)

            request = UNNotificationRequest(identifier: NotificationServiceKeys.selfTestPush,
                                                        content: content,
                                                        trigger: trigger)
        } else {

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: false)

            request = UNNotificationRequest(identifier: NotificationServiceKeys.selfTestPush,
                                                        content: content,
                                                        trigger: trigger)
        }
        
        notificationCenter.add(request)
    }
    
    func removeSelfTestReminderNotification() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [NotificationServiceKeys.selfTestPush])
    }

    func showNotificationFor(_ infectionWarning: InfectionWarning) {
        switch infectionWarning.type {
        case .red:
            showCertifiedSickContactNotification(infectionWarning)
        case .yellow:
            showSuspectedSickContactNotification(infectionWarning)
        case .green:
            break
        }
    }
}

private extension Date {
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
}
