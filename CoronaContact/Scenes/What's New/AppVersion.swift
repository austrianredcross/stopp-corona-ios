//
//  AppVersion.swift
//  CoronaContact
//

import UIKit

protocol AppInfo {
    var appVersion: AppVersion { get }
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
    var appVersion: AppVersion {
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

public struct AppVersion: Codable, Comparable, Hashable, CustomStringConvertible {

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

    /// A version object for an app that has not been installed previously
    ///
    /// This object is used as the default version when checking for the previously installed
    /// app version. When comparing the current app version against `notPreviouslyInstalled`,
    /// the current version is lower, therefore the what's new info will not be shown on new installations.
    ///
    /// - note: `notPreviouslyInstalled > any other AppVersion`
    public static var notPreviouslyInstalled: AppVersion {
        AppVersion(major: .max, minor: .max, patch: .max)
    }

    public static var current: AppVersion {
        UIApplication.shared.appVersion
    }
    
    public var description: String {
        "\(major).\(minor).\(patch)"
    }
}

extension AppVersion: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(versionString: value)!
    }
}
