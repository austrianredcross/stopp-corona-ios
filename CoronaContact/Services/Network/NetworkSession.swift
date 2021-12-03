//
//  NetworkSession.swift
//  CoronaContact
//

import Alamofire
import Foundation

class NetworkSession {
    static func session() -> Alamofire.Session {
        // Setup certificates for SSL pinning in order to mitigate MITM attacks
        let evaluators = [
            AppConfiguration.apiHostName: PublicKeysTrustEvaluator(),
            AppConfiguration.apiSmsHostName: PublicKeysTrustEvaluator(),
            AppConfiguration.apiCdnHostName: PublicKeysTrustEvaluator(),
        ]
        let trustManager = ServerTrustManager(evaluators: evaluators)
        let configuration = URLSessionConfiguration.af.default

        #if DEBUG || STAGE
            LoggingService.debug("SSL Pinning is disabled for development and stage ", context: .network)
            return Alamofire.Session.default
        #else
            return Alamofire.Session(configuration: configuration, serverTrustManager: trustManager)
        #endif
    }

    static func backgroundSession(url: URL, headers: HTTPHeaders = ["Content-Type": "application/json",
                                                           "Accept": "application/json",
                                                           "Accept-Encoding": "application/json"],
                                  completion: @escaping (URL) -> Void) throws {
        
        let configuration = URLSessionConfiguration.background(withIdentifier: "downloadBackground_session")
        
        DownloadSessionDelegate.shared.downloadCompleted = completion
        
        guard let request  = try? URLRequest(url: url, method: .post, headers: headers) else { throw URLError(.badURL) }

         let task = URLSession(configuration: configuration, delegate: DownloadSessionDelegate.shared, delegateQueue: nil).downloadTask(with: request)
         task.resume()
    }
}

// When using downloadTask with completions you have to create a class that conforms the URLSessionDelegate
class DownloadSessionDelegate: NSObject, URLSessionDelegate, URLSessionDownloadDelegate {
    var downloadCompleted: ((URL) -> Void)?
    
    static let shared = DownloadSessionDelegate()

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // Return the location with the completion
        downloadCompleted?(location)
    }
}
