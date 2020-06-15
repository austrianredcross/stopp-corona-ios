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

    static func makeDestination(for url: URL) -> DownloadDestination {
        // swiftformat:disable:next redundantReturn
        return { temporaryURL, response in
            let (_, options) = defaultDestination(temporaryURL, response)

            return (url, options)
        }
    }
}
