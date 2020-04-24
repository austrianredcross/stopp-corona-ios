//
//  Certificates.swift
//  CoronaContact
//

import Foundation

struct Certificates {
    static let staging =
            Certificates.publicKey(filename: "")

    private static func publicKey(filename: String) -> SecKey {
        let filePath = Bundle.main.path(forResource: filename, ofType: "der")!
        let data = try? Data(contentsOf: URL(fileURLWithPath: filePath))
        let certificate = SecCertificateCreateWithData(nil, data! as CFData)

        var trust: SecTrust?
        let policy = SecPolicyCreateBasicX509()
        _ = SecTrustCreateWithCertificates(certificate!, policy, &trust)
        return SecTrustCopyPublicKey(trust!)!
    }
}
