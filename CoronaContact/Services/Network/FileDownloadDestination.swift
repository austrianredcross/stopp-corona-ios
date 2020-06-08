//
//  FileDownloadDestination.swift
//  CoronaContact
//

import Alamofire
import Foundation
import Moya

struct FileDownloadDestination {
    static let defaultDestination: DownloadDestination = DownloadRequest.suggestedDownloadDestination(
        for: .documentDirectory,
        in: .userDomainMask,
        options: [.removePreviousFile, .createIntermediateDirectories]
    )

    static func makeDestination(appending pathComponents: [String]) -> DownloadDestination {
        { url, response in
            var (destinationURL, options) = defaultDestination(url, response)
            destinationURL = destinationURL.deletingLastPathComponent()
            pathComponents.forEach { destinationURL.appendPathComponent($0) }

            return (destinationURL, options)
        }
    }
}
