//
//  ReportHealthStatusFlowController.swift
//  CoronaContact
//

import ExposureNotification
import Foundation
import Resolver

class ReportHealthStatusFlowController {
    @Injected private var exposureManager: ExposureManager
    @Injected private var exposureKeyManager: ExposureKeyManager
    @Injected private var networkService: NetworkService

    typealias Completion<Success> = (Result<Success, ReportError>) -> Void

    enum ReportError: Error {
        case unknown
        case tanConfirmation(NetworkService.DisplayableError)
        case submission(NetworkService.TracingKeysError)
    }

    private let diagnosisType: DiagnosisType
    private var tanUUID: String?
    private var verification: Verification?
    var personalData: PersonalData?

    init(diagnosisType: DiagnosisType) {
        self.diagnosisType = diagnosisType
    }

    func tanConfirmation(personalData: PersonalData, completion: @escaping Completion<Void>) {
        self.personalData = personalData

        networkService.requestTan(mobileNumber: personalData.mobileNumber) { [weak self] result in
            switch result {
            case let .success(response):
                self?.tanUUID = response.uuid
                completion(.success(()))
            case let .failure(error):
                completion(.failure(.tanConfirmation(error)))
            }
        }
    }

    func statusReport(tanNumber: String) {
        guard let tanUUID = tanUUID else {
            return
        }

        verification = Verification(uuid: tanUUID, authorization: tanNumber)
    }

    func submit(completion: @escaping Completion<Void>) {
        getDiagnoisKeys { [weak self] result in
            switch result {
            case let .success(tracingKeys):
                self?.sendTracingKeys(tracingKeys, completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    private func getDiagnoisKeys(completion: @escaping Completion<TracingKeys>) {
        guard let verification = verification else {
            failSilently(completion)
            return
        }

        exposureManager.getDiagnosisKeys { [weak self] result in
            guard let self = self else {
                return
            }

            switch result {
            case let .success(temporaryExposureKeys):
                let tracingKeys = self.parseTemporaryExposureKeys(temporaryExposureKeys, verification: verification)
                completion(.success(tracingKeys))
            case let .failure(error):
                LoggingService.error("Couldn't get diagnosis keys from the exposure manager: \(error)", context: .exposure)
                self.failSilently(completion)
            }
        }
    }

    private func parseTemporaryExposureKeys(_ temporaryExposureKeys: [ENTemporaryExposureKey],
                                            verification: Verification) {
        let temporaryExposureKeys = exposureKeyManager.getKeysForUpload(keys: temporaryExposureKeys)

        tracingKeys = TracingKeys(
            temporaryExposureKeys: temporaryExposureKeys,
            diagnosisType: diagnosisType,
            verificationPayload: verification
        )
    }

    private func sendTracingKeys(_ tracingKeys: TracingKeys, completion: @escaping Completion<Void>) {
        networkService.sendTracingKeys(tracingKeys) { result in
            switch result {
            case .success:
                completion(.success(()))
            case let .failure(error):
                completion(.failure(.submission(error)))
            }
        }
    }

    private func failSilently<Success>(_ completion: @escaping Completion<Success>) {
        completion(.failure(.unknown))
    }
}
