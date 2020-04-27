//
//  NotificationToken.swift
//  CoronaContact
//

import Foundation

/// Wraps the observer token received from
/// NotificationCenter.addObserver(forName:object:queue:using:)
/// and unregisters it in deinit.
///
/// If you want to learn more about this, please have a look at
/// Ole Begemann's [blog post](https://oleb.net/blog/2018/01/notificationcenter-removeobserver/).
final public class NotificationToken: NSObject {
    let notificationCenter: NotificationCenter
    let token: Any

    init(notificationCenter: NotificationCenter = .default, token: Any) {
        self.notificationCenter = notificationCenter
        self.token = token
    }

    deinit {
        notificationCenter.removeObserver(token)
    }
}
