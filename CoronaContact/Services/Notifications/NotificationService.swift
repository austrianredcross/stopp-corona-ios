//
//  NotificationService.swift
//  CoronaContact
//

import UIKit
import UserNotifications
import Resolver

struct NotificationServiceKeys {
    static let selfTestPush = "selfTestPush"
    static let quarantineCompleted = "quarantineCompleted"
}

class NotificationService: NSObject {
    let notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()

    private lazy var dateComponents: (_ date: Date) -> DateComponents = { date in
        Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
    }

    func dismissAllNotifications() {
        notificationCenter.removeAllDeliveredNotifications()
        notificationCenter.removeAllPendingNotificationRequests()
    }

    func askForPermissions() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if error != nil {
                print("there was an \(error.debugDescription) when registering notifications, it was granted:\(granted)")
            }
        }
    }

    func showSuspectedSickContactNotification(_ warning: InfectionWarning) {
        let title = "local_notification_suspected_sick_contact_headline".localized
        let body = "local_notification_suspected_sick_contact_message".localized
        self.showNotification(title: title, body: body)
    }

    func showCertifiedSickContactNotification(_ warning: InfectionWarning) {
        let title = "local_notification_sick_contact_headline".localized
        let body = "local_notification_sick_contact_message".localized
        self.showNotification(title: title, body: body)
    }

    func showQuarantineCompletedNotification(endOfQuarantine: Date) {
        let title = "local_notification_sick_contact_headline".localized
        let body = "local_notification_sick_contact_message".localized

        showNotification(
            identifier: NotificationServiceKeys.quarantineCompleted,
            title: title,
            body: body,
            at: endOfQuarantine
        )
    }

    func showTestNotifications() {
        addSelfTestReminderNotificationIn(seconds: 10)

        let titleRed = "TEST: \("local_notification_sick_contact_headline".localized))"
        let bodyRed = "local_notification_sick_contact_message".localized
        self.showNotification(title: titleRed, body: bodyRed, delay: 5)

        let titleYellow = "TEST: \("local_notification_suspected_sick_contact_headline".localized)"
        let bodyYellow = "local_notification_suspected_sick_contact_message".localized
        self.showNotification(title: titleYellow, body: bodyYellow, delay: 5)
    }

    func showNotification(title: String, body: String, delay: Int = 0) {
        let content = UNMutableNotificationContent()

        content.title = title
        content.body = body

        content.categoryIdentifier = "alarm"

        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString,
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
