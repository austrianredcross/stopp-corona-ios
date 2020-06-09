//
//  BatchDownloadSchedulerResult.swift
//  CoronaContact
//

import BackgroundTasks
import Foundation

enum BatchDownloadSchedulerError: Error {
    case backgroundTimeout
    case download(BatchDownloadError)
}

struct BatchDownloadSchedulerResult: CustomStringConvertible {
    let task: BGTask
    let error: BatchDownloadSchedulerError?
    let date = Date()

    init(task: BGTask, error: BatchDownloadSchedulerError?) {
        self.task = task
        self.error = error
    }

    var description: String {
        var result = "Task \(task.identifier)"

        if let error = error {
            result += " failed at \(date) because "

            switch error {
            case .backgroundTimeout:
                result += "the background task ran out of background time."
            case let .download(.unzip(error)):
                result += "one of the batches could not be decompressed: \(error)."
            case let .download(.network(error)):
                result += "of a network issue: \(error)."
            case .download(.cancelled):
                result += "because one of the network requests was cancelled."
            case .download(.noResult):
                assertionFailure()
                result += "because of an unexpected error in the business logic."
            }
        } else {
            result += " was completed successfully at \(date)."
        }

        return result
    }
}
