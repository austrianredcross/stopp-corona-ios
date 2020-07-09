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

        return Alamofire.Session(configuration: configuration, serverTrustManager: trustManager)
    }
}
