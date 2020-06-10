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

        #if DEBUG
            LoggingService.debug("SSL Pinning is disabled during development", context: .network)
            return Alamofire.Session.default
        #else
            return Alamofire.Session(configuration: configuration, serverTrustManager: trustManager)
        #endif
    }
}
