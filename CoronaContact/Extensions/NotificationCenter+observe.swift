//
//  NotificationCenter+observe.swift
//  CoronaContact
//

import Foundation

extension NotificationCenter {
    /// Convenience wrapper for addObserver(forName:object:queue:using:)
    /// that returns our custom NotificationToken.
    ///
    /// If you want to learn more about this, please have a look at
    /// Ole Begemann's [blog post](https://oleb.net/blog/2018/01/notificationcenter-removeobserver/).
    func observe(name: NSNotification.Name?,
                 object obj: Any?,
                 queue: OperationQueue?,
                 using block: @escaping (Notification) -> Void) -> NotificationToken
    {
        let token = addObserver(forName: name, object: obj, queue: queue, using: block)
        return NotificationToken(notificationCenter: self, token: token)
    }
}
