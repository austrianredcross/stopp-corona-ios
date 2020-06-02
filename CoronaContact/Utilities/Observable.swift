//
//  Observable.swift
//  CoronaContact
//

import Foundation

final class Subscription<T> {
    typealias Callback = (T) -> Void
    private let callback: Callback

    init(callback: @escaping Callback) {
        self.callback = callback
    }

    func send(_ value: T) {
        callback(value)
    }
}

final class AnySubscription: Hashable {
    private let subscription: Any
    private let identifier: ObjectIdentifier

    init<T>(_ subscription: Subscription<T>) {
        self.subscription = subscription
        identifier = ObjectIdentifier(subscription)
    }

    func add(to subscriptions: inout Set<AnySubscription>) {
        subscriptions.insert(self)
    }

    static func == (lhs: AnySubscription, rhs: AnySubscription) -> Bool {
        lhs.identifier == rhs.identifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

final class WeakBox<A: AnyObject> {
    weak var unbox: A?
    init(_ value: A) {
        unbox = value
    }
}

struct WeakArray<Element: AnyObject> {
    private var items: [WeakBox<Element>] = []

    init(_ elements: [Element]) {
        items = elements.map { WeakBox($0) }
    }

    init() {}
}

extension WeakArray: Collection {
    var startIndex: Int { items.startIndex }
    var endIndex: Int { items.endIndex }

    subscript(_ index: Int) -> Element? {
        items[index].unbox
    }

    func index(after idx: Int) -> Int {
        items.index(after: idx)
    }

    mutating func append(_ newElement: Element) {
        items.append(.init(newElement))
    }

    mutating func remove(at index: Int) -> Element? {
        items.remove(at: index).unbox
    }

    mutating func removeEmptyReferences() {
        items = items.filter { $0.unbox != nil }
    }
}

struct Subscribable<T> {
    private var subscriptions = WeakArray<Subscription<T>>()

    mutating func subscribe(_ callback: @escaping Subscription<T>.Callback) -> AnySubscription {
        let subscription = Subscription(callback: callback)
        subscriptions.append(subscription)
        return AnySubscription(subscription)
    }

    fileprivate mutating func send(_ value: T) {
        subscriptions.removeEmptyReferences()
        let subscriptions = self.subscriptions
        DispatchQueue.main.async {
            for subscription in subscriptions {
                subscription?.send(value)
            }
        }
    }
}

@propertyWrapper struct Observable<T> {
    var wrappedValue: T {
        didSet {
            projectedValue.send(wrappedValue)
        }
    }

    var projectedValue = Subscribable<T>()

    init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
}
