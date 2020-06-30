//
//  LoggingService.swift
//  CoronaContact
//

import Foundation
import SwiftyBeaver

enum LoggingContext: String {
    case `default`
    case network
    case handshake
    case navigation
    case database
    case application
    case bluetooth
    case exposure
    case storage
    case batchDownload
    case riskCalculation
    case notifications

    var description: String {
        rawValue.uppercased()
    }
}

class LoggingService {
    static var logFileURL: URL {
        let folderURLs = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return folderURLs[0].appendingPathComponent("application.log")
    }

    static func configure(logFileURL: URL = logFileURL) {
        let console = ConsoleDestination()
        console.minLevel = .debug
        console.format = "$DHH:mm:ss.SSS$d $C[$X] $L$c $N.$F:$l - $M"

        let file = FileDestination(logFileURL: logFileURL)
        file.minLevel = .verbose
        file.format = "$Dyyyy-MM-dd HH:mm:ss.SSS$d $C[$X] $L$c $N.$F:$l - $M"

        #if DEBUG
            file.asynchronously = false
        #endif

        #if LOGGING
            SwiftyBeaver.addDestination(console)
            SwiftyBeaver.addDestination(file)
        #endif
    }

    @discardableResult
    static func deleteLogFile() -> Bool {
        guard let fileDestination = SwiftyBeaver.destinations.first(where: { $0 is FileDestination }) as? FileDestination else {
            return false
        }

        return fileDestination.deleteLogFile()
    }

    class func verbose(_ message: Any, _ file: String = #file, _ function: String = #function,
                       line: Int = #line, context: LoggingContext = .default) {
        SwiftyBeaver.verbose(message, file, function, line: line, context: context.description)
    }

    class func debug(_ message: Any, _ file: String = #file, _ function: String = #function,
                     line: Int = #line, context: LoggingContext = .default) {
        SwiftyBeaver.debug(message, file, function, line: line, context: context.description)
    }

    class func info(_ message: Any, _ file: String = #file, _ function: String = #function,
                    line: Int = #line, context: LoggingContext = .default) {
        SwiftyBeaver.info(message, file, function, line: line, context: context.description)
    }

    class func warning(_ message: Any, _ file: String = #file, _ function: String = #function,
                       line: Int = #line, context: LoggingContext = .default) {
        SwiftyBeaver.warning(message, file, function, line: line, context: context.description)
    }

    class func error(_ message: Any, _ file: String = #file, _ function: String = #function,
                     line: Int = #line, context: LoggingContext = .default) {
        SwiftyBeaver.error(message, file, function, line: line, context: context.description)
    }
}

func registerLoggingeService() {
    LoggingService.configure()
}
