//
//  PersistedWrapper.swift
//  CoronaContact
//

import Foundation

@propertyWrapper
class Persisted<Value: Codable> {
    let log = ContextLogger(context: .storage)

    init(userDefaultsKey: String, notificationName: Notification.Name, defaultValue: Value) {
        self.userDefaultsKey = userDefaultsKey
        self.notificationName = notificationName
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
            do {
                wrappedValue = try JSONDecoder().decode(Value.self, from: data)
            } catch {
                wrappedValue = defaultValue
            }
        } else {
            wrappedValue = defaultValue
        }
    }

    let userDefaultsKey: String
    let notificationName: Notification.Name

    var wrappedValue: Value {
        didSet {
            log.debug("changed value \(userDefaultsKey) to \(wrappedValue)")
            UserDefaults.standard.set(try? JSONEncoder().encode(wrappedValue), forKey: userDefaultsKey)
            NotificationCenter.default.post(name: notificationName, object: nil)
        }
    }

    var projectedValue: Persisted<Value> {
        self
    }

    // swiftlint:disable discarded_notification_center_observer
    // disabled because of false positive warning, the observer is not discarded but returned
    func addObserver(using block: @escaping () -> Void) -> NSObjectProtocol {
        NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: nil) { _ in
            block()
        }
    }
    // swiftlint:enable discarded_notification_center_observer
}
