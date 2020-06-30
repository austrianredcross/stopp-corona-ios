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
}

class NotificationService: NSObject {
    @Injected private var localStorage: LocalStorage
    private let notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()
    private let log = ContextLogger(context: .notifications)
    private var observers = [NSObjectProtocol]()

    private lazy var dateComponents: (_ date: Date) -> DateComponents = { date in
        Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
    }

    override init() {
        super.init()
        observers.append(localStorage.$missingUploadedKeysAt.addObserver(using: registerMissingKeysReminder))
    }

    func dismissAllNotifications() {
        notificationCenter.removeAllDeliveredNotifications()
        notificationCenter.removeAllPendingNotificationRequests()
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
        addSelfTestReminderNotificationIn(seconds: 10)

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

    func addSelfTestReminderNotificationIn(seconds: TimeInterval = 60 * 60 * 6) {
        removeSelfTestReminderNotification()

        let content = UNMutableNotificationContent()
        content.title = "self_test_push_reminder".localized

        content.categoryIdentifier = "alarm"
        content.sound = UNNotificationSound.default
        content.userInfo = ["type": NotificationServiceKeys.selfTestPush]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)

        let request = UNNotificationRequest(identifier: NotificationServiceKeys.selfTestPush,
                                            content: content,
                                            trigger: trigger)

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
