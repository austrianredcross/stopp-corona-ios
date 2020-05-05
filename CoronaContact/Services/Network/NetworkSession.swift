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
            AppConfiguration.apiHostName: PublicKeysTrustEvaluator()
        ]
        let trustManager = ServerTrustManager(evaluators: evaluators)
        let configuration = URLSessionConfiguration.af.default
        return Alamofire.Session(configuration: configuration, serverTrustManager: trustManager)
    }
}
