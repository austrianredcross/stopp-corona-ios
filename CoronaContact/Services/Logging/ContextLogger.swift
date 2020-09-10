//
//  ContextLogger.swift
//  CoronaContact
//

import Foundation
import SwiftyBeaver

/**
 * the ContextLogger provides an alternative frontend to the logging framework
 *
 * it allows to easily log messages to a single context and to change the minimum
 * severity for this logger during and after development
 */
class ContextLogger {
    var context: LoggingContext
    var minLevel: SwiftyBeaver.Level

    init(context: LoggingContext, minLevel: SwiftyBeaver.Level? = .verbose) {
        self.context = context
        self.minLevel = .verbose
    }

    func verbose(_ message: Any, _ file: String = #file, _ function: String = #function,
                 line: Int = #line)
    {
        if minLevel.rawValue <= SwiftyBeaver.Level.debug.rawValue {
            SwiftyBeaver.verbose(message, file, function, line: line, context: context.description)
        }
    }

    func debug(_ message: Any, _ file: String = #file, _ function: String = #function,
               line: Int = #line)
    {
        if minLevel.rawValue <= SwiftyBeaver.Level.debug.rawValue {
            SwiftyBeaver.debug(message, file, function, line: line, context: context.description)
        }
    }

    func info(_ message: Any, _ file: String = #file, _ function: String = #function,
              line: Int = #line)
    {
        if minLevel.rawValue <= SwiftyBeaver.Level.info.rawValue {
            SwiftyBeaver.info(message, file, function, line: line, context: context.description)
        }
    }

    func warning(_ message: Any, _ file: String = #file, _ function: String = #function,
                 line: Int = #line)
    {
        if minLevel.rawValue <= SwiftyBeaver.Level.warning.rawValue {
            SwiftyBeaver.warning(message, file, function, line: line, context: context.description)
        }
    }

    func error(_ message: Any, _ file: String = #file, _ function: String = #function,
               line: Int = #line)
    {
        SwiftyBeaver.error(message, file, function, line: line, context: context.description)
    }
}
