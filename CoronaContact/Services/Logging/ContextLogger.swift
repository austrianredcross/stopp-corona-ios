//
//  ContextLogger.swift
//  CoronaContact
//

import Foundation
import SwiftyBeaver

class ContextLogger {
    var context: LoggingContext

    init(context: LoggingContext) {
        self.context = context
    }

    func verbose(_ message: Any, _ file: String = #file, _ function: String = #function,
                 line: Int = #line) {
        SwiftyBeaver.verbose(message, file, function, line: line, context: context.description)
    }

    func debug(_ message: Any, _ file: String = #file, _ function: String = #function,
               line: Int = #line) {
        SwiftyBeaver.debug(message, file, function, line: line, context: context.description)
    }

    func info(_ message: Any, _ file: String = #file, _ function: String = #function,
              line: Int = #line) {
        SwiftyBeaver.info(message, file, function, line: line, context: context.description)
    }

    func warning(_ message: Any, _ file: String = #file, _ function: String = #function,
                 line: Int = #line) {
        SwiftyBeaver.warning(message, file, function, line: line, context: context.description)
    }

    func error(_ message: Any, _ file: String = #file, _ function: String = #function,
               line: Int = #line) {
        SwiftyBeaver.error(message, file, function, line: line, context: context.description)
    }
}
