//
//  AppVersion.swift
//  CoronaContact
//

import UIKit

protocol AppInfo {
    func appVersion() -> AppVersion
}

extension Bundle {
    var appVersion: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var appBuild: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}

extension UIApplication: AppInfo {
    func appVersion() -> AppVersion {
        let bundle = Bundle.main
        guard
            let versionString = bundle.appVersion,
            let version = AppVersion(versionString: versionString)
        else {
            assertionFailure()
            return AppVersion(major: 0, minor: 0, patch: 1)
        }

        return version
    }
}

public struct AppVersion: Codable, Comparable {

    /// The `2` in `2.5.1`
    public let major: Int

    /// The `5` in `2.5.1`
    public let minor: Int

    /// The `1` in `2.5.1`
    public let patch: Int

    public init(major: Int, minor: Int, patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    /// Initializes an `AppVersion` with a string of the form `"2.5.1"`
    ///
    /// The `versionString` must at least have a major version number.
    /// Minor and patch numbers will be substituted with zeros if not available.
    init?(versionString: String) {
        var numbers = versionString
            .components(separatedBy: ".")
            .compactMap { Int($0) }

        guard !numbers.isEmpty else {
            return nil
        }

        while numbers.count < 3 {
            numbers.append(0)
        }

        self.init(major: numbers[0], minor: numbers[1], patch: numbers[2])
    }

    public static func < (lhs: AppVersion, rhs: AppVersion) -> Bool {
        lhs.major < rhs.major || lhs.minor < rhs.minor || lhs.patch < rhs.patch
    }

    public static var notPreviouslyInstalled: AppVersion {
        AppVersion(major: 0, minor: 0, patch: 0)
    }

    public static var current: AppVersion {
        UIApplication.shared.appVersion()
    }
}
