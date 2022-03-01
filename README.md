# Stopp Corona iOS App

**Important**: The development has stopped with **28.02.2022**

---

„Stopp Corona“ helps you to keep track of encounters with friends, family or co-workers and save them anonymously. Should you contract the corona virus all your encounters of the last 48 hours will be informed automatically and anonymously.

[![App Store Download Link](.github/app-store-badge.png)](https://apps.apple.com/at/app/apple-store/id1503717224)

## About

The **Stopp Corona** project is an open source project for bluetooth based contact
tracing deployed by the Austrian Red Cross in Austria.  For developers interested
in contributing, other organizations interested in joining forces please have a look
at the following documents:

* [Covenant](https://github.com/austrianredcross/meta/blob/master/COVENANT.md): the project's ideals and goals
* [Cooperation and Funding](https://github.com/austrianredcross/meta/blob/master/COOPERATION.md): support the development or join the project
* [Code of Conduct](https://github.com/austrianredcross/meta/blob/master/CODE_OF_CONDUCT.md): fair guidelines for a friendly discourse

## Getting Started

### Requirements

* Xcode 11
* CocoaPods (v1.9.1 or higher)

### Installation

1. Clone this repository.
2. `cd` to the project's directory and run `pod install` to install the third party dependencies. In case your spec sources are out of date, run `pod install --repo-update` instead.
3. Open `CoronaContact.xcworkspace`
4. You will need to provide your own app secrets in order to run the app. **The app will not build when you do not provide these values**. They can be set in the following places:
    1. There is a template for a `Secrets.xcconfig` file in the `Configuration` folder. It contains keys for defining the API base URL and the API authorization key for the staging and production environment.
    2. Copy the public server certificate as `Configuration/server.der` into the project. If you don't want to use certificate pinning you have to disable it in `Services/Network/Networksession.swift`
5. You can choose between three different build schemes:
    1. *CoronaContact (Development)*: used for development, uses staging environment
    2. *CoronaContact (Staging)*: uses staging environment
    3. *CoronaContact (Production)*: uses production environment

### SSL Pinning

To add SSL pinning the certificates have to be included in the app bundle and the domains have to be configured in the file `CoronaContact/Services/Network/NetworkSession.swift`.
It’s possible to configure certificate pinning or public key pinning as described in the [documentation](https://github.com/Alamofire/Alamofire/blob/master/Documentation/AdvancedUsage.md#security).

## Dependencies

CocoaPods is used to manage third-party dependencies. Please make sure you have Cocoapods installed. Before starting, please `cd` to the project's directory and run `pod install`. For more information visit [cocoapods.org](https://cocoapods.org).

### Third Party

* [Carte](https://github.com/devxoul/Carte)
* [lottie](https://github.com/airbnb/lottie-ios)
* [M13Checkbox](https://github.com/Marxon13/M13Checkbox)
* [Moya](https://github.com/Moya/Moya)
* [Resolver](https://github.com/hmlongco/Resolver)
* [Reusable](https://github.com/AliSoftware/Reusable)
* [SQLite](https://github.com/stephencelis/SQLite.swift)
* [SQLiteMigrationManager](https://github.com/garriguv/SQLiteMigrationManager.swift)
* [SwiftLint](https://github.com/realm/SwiftLint)
* [SwiftRichString](https://github.com/malcommac/SwiftRichString)
* [SwiftyBeaver](https://github.com/SwiftyBeaver/SwiftyBeaver)
* [ZIPFoundation](https://github.com/weichsel/ZIPFoundation)
* [GEOSwift](https://github.com/GEOSwift/GEOSwift)

Notices for third party libraries in this repository are contained in `NOTICE.md`.

## License

This code is distributed under the Apache License 2.0. See the `LICENSE.txt` file for more info.
