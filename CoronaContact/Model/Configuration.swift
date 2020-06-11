//
//  Configuration.swift
//  CoronaContact
//

import Foundation

// MARK: - Configuration

struct Configuration: Codable {
    private enum CodingKeys: String, CodingKey {
        case warnBeforeSymptoms = "warn_before_symptoms"
        case redWarningQuarantine = "red_warning_quarantine"
        case yellowWarningQuarantine = "yellow_warning_quarantine"
        case selfDiagnosedQuarantine = "self_diagnosed_quarantine"
        case diagnosticQuestionnaire = "diagnostic_questionnaire"
        case uploadKeyDays = "upload_keys_days"
    }

    let warnBeforeSymptoms: Int
    /// Quarantine duration for infected contacts in hours
    let redWarningQuarantine: Int
    /// Quarantine duration for possibly infected contacts in hours
    let yellowWarningQuarantine: Int
    /// Quarantine duration for possibly infected user (determined by self test) in hours
    let selfDiagnosedQuarantine: Int
    let diagnosticQuestionnaire: [Language: Questionnaire?]

    /// Days we should upload from the past when uploading keys
    let uploadKeyDays: Int
}

// MARK: Decodable

extension Configuration {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let questionnaireContainer = try container.nestedContainer(keyedBy: Language.CodingKeys.self, forKey: .diagnosticQuestionnaire)

        var questionnaires = [Language: Questionnaire?]()
        for languageKey in questionnaireContainer.allKeys {
            guard let language = Language(rawValue: languageKey.rawValue) else {
                let context = DecodingError.Context(
                    codingPath: [],
                    debugDescription: "Could not parse language \(languageKey.rawValue) to a Language object"
                )
                throw DecodingError.dataCorrupted(context)
            }
            let value = try questionnaireContainer.decodeIfPresent(Questionnaire.self, forKey: languageKey)
            questionnaires[language] = value
        }
        diagnosticQuestionnaire = questionnaires
        warnBeforeSymptoms = try container.decode(Int.self, forKey: .warnBeforeSymptoms)
        redWarningQuarantine = try container.decode(Int.self, forKey: .redWarningQuarantine)
        yellowWarningQuarantine = try container.decode(Int.self, forKey: .yellowWarningQuarantine)
        selfDiagnosedQuarantine = try container.decode(Int.self, forKey: .selfDiagnosedQuarantine)
        uploadKeyDays = try container.decode(Int.self, forKey: .uploadKeyDays)
    }
}

// MARK: - ConfigurationRespone

struct ConfigurationResponse: Codable {
    let configuration: Configuration
}
