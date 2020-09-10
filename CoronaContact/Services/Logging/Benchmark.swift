//
//  Benchmark.swift
//  CoronaContact
//

import Foundation

class Benchmark {
    let name: String
    let thread = Thread.self
    var started = Date()
    var lastCheckPoint = Date()

    init(name: String) {
        self.name = name
    }

    func checkPoint(message: String) {
        let now = Date()
        assert(Thread.self == thread)
        let passed = String(format: "%0.3f", now.timeIntervalSince1970 - lastCheckPoint.timeIntervalSince1970)
        let all = String(format: "%0.3f", now.timeIntervalSince1970 - started.timeIntervalSince1970)
        LoggingService.info("Benchmark:\(name) Checkpoint:'\(message)' Passed: \(passed) Gesamt: \(all)")
        lastCheckPoint = now
    }
}
