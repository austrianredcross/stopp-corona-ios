//
//  AsyncOperation.swift
//  CoronaContact
//

import Foundation

class AsyncOperation: Operation {
    private let lockQueue = DispatchQueue(label: "AsyncOperation.lockQueue")

    override var isAsynchronous: Bool {
        true
    }

    private var _isExecuting: Bool = false
    override private(set) var isExecuting: Bool {
        get {
            lockQueue.sync { () -> Bool in
                _isExecuting
            }
        }
        set {
            willChangeValue(forKey: "isExecuting")
            lockQueue.sync(flags: [.barrier]) {
                _isExecuting = newValue
            }
            didChangeValue(forKey: "isExecuting")
        }
    }

    private var _isFinished: Bool = false
    override private(set) var isFinished: Bool {
        get {
            lockQueue.sync { () -> Bool in
                _isFinished
            }
        }
        set {
            willChangeValue(forKey: "isFinished")
            lockQueue.sync(flags: [.barrier]) {
                _isFinished = newValue
            }
            didChangeValue(forKey: "isFinished")
        }
    }

    override func start() {
        guard !isCancelled else {
            finish()
            return
        }

        isFinished = false
        isExecuting = true
        main()
    }

    override func main() {
        fatalError("Subclasses must implement `main` without overriding super.")
    }

    func finish() {
        isExecuting = false
        isFinished = true
    }
}

class AsyncResultOperation<Success, Failure>: AsyncOperation where Failure: Error {
    private(set) var result: Result<Success, Failure>?

    override final func finish() {
        guard !isCancelled else { return super.finish() }
        fatalError("Make use of finish(with:) instead to ensure a result")
    }

    func finish(with result: Result<Success, Failure>) {
        self.result = result
        super.finish()
    }

    override open func cancel() {
        fatalError("Make use of cancel(with:) instead to ensure a result")
    }

    func cancel(with error: Failure) {
        result = .failure(error)
        super.cancel()
    }
}

class ChainedAsyncResultOperation<Input, Output, Failure>: AsyncResultOperation<Output, Failure> where Failure: Swift.Error {
    private(set) var input: Input?

    init(input: Input? = nil) {
        self.input = input
    }

    override final func start() {
        updateInputFromDependencies()
        super.start()
    }

    /// Updates the input by fetching the output of its dependencies.
    /// Will always get the first output matching dependency.
    /// If `input` is already set, the input from dependencies will be ignored.
    private func updateInputFromDependencies() {
        guard input == nil else { return }
        input = dependencies.compactMap { dependency in
            (dependency as? ChainedOperationOutputProviding)?.output as? Input
        }.first
    }
}

protocol ChainedOperationOutputProviding {
    var output: Any? { get }
}

extension ChainedAsyncResultOperation: ChainedOperationOutputProviding {
    var output: Any? {
        try? result?.get()
    }
}
