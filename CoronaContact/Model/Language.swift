//
//  Language.swift
//  CoronaContact
//

import Foundation

enum Language: String, Codable, CaseIterable {

    enum CodingKeys: String, CodingKey {
        case
        german = "de",
        english = "en",
        french = "fr",
        hungarian = "hu",
        czech = "cz",
        slovak = "sk",
        unknown = "HINT"
    }

    case german = "de"
    case english = "en"
    case french = "fr"
    case hungarian = "hu"
    case czech = "cz"
    case slovak = "sk"
    case unknown = "HINT"

    static var current: Language {
        let languageCode = "current_language".localized

        guard let supportedLanguage = Language(rawValue: languageCode) else {
            return .english
        }

        return supportedLanguage
    }
}
