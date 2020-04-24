//
//  NetworkService+Error.swift
//  CoronaContact
//

import Foundation

// MARK: - Error handling

extension NetworkService {

    private static let generalServerError = DisplayableError(
        title: "general_server_error".localized,
        description: "general_server_connection_error_description".localized
    )

    struct DisplayableError: Error {

        let title: String
        let description: String
    }

    struct InfectionInfoError: Error {

        let displayableError: DisplayableError
        let personalDataInvalid: Bool
        let tanInvalid: Bool
    }

    func parseInfectionInfoError(statusCode: HTTPStatusCode?) -> InfectionInfoError {
        switch statusCode?.rawValue {
        case 400:
            let displayableError = DisplayableError(
                title: "sickness_certificate_report_status_invalid_birth_date_error".localized,
                description: "sickness_certificate_report_status_invalid_birth_date_error_description".localized
            )
            return InfectionInfoError(displayableError: displayableError, personalDataInvalid: true, tanInvalid: false)
        case 403:
            let displayableError = DisplayableError(
                title: "sickness_certificate_report_status_invalid_tan_error".localized,
                description: "sickness_certificate_report_status_invalid_tan_error_description".localized
            )
            return InfectionInfoError(displayableError: displayableError, personalDataInvalid: false, tanInvalid: true)
        default:
            return InfectionInfoError(displayableError: Self.generalServerError, personalDataInvalid: false, tanInvalid: false)
        }
    }

    func parseTanEror(statusCode: HTTPStatusCode?) -> DisplayableError {
        switch statusCode?.rawValue {
        case 401:
            return DisplayableError(
                title: "sickness_certificate_personal_data_invalid_mobile_number_error".localized,
                description: "sickness_certificate_personal_data_invalid_mobile_number_error_description".localized
            )
        default:
            return Self.generalServerError
        }
    }

    func filterStatusCode(_ statusCode: Int) {
        if statusCode == 410 {
            appUpdateService.requiresUpdate = true
        }
    }
}
