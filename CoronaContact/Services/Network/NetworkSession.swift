//
//  NetworkAlamofireManager.swift
//  CoronaContact
//

import Foundation
import Alamofire

class NetworkSession {
    static func session() -> Alamofire.Session {
        // Setup certificates for SSL pinning in order to mitigate MITM attacks
        let evaluators = [
            AppConfiguration.apiHostName: PublicKeysTrustEvaluator(),
            AppConfiguration.apiSmsHostName: PublicKeysTrustEvaluator()
        ]
        let trustManager = ServerTrustManager(evaluators: evaluators)
        let configuration = URLSessionConfiguration.af.default

        #if DEBUG
        return Alamofire.Session.default
        #else
        return Alamofire.Session(configuration: configuration, serverTrustManager: trustManager)
        #endif
    }
}
