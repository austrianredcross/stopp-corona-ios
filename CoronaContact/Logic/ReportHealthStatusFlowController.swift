//
//  ReportHealthStatusFlowController.swift
//  CoronaContact
//

import ExposureNotification
import Foundation
import Resolver

class ReportHealthStatusFlowController {
    @Injected private var exposureManager: ExposureManager
    @Injected var exposureKeyManager: ExposureKeyManager
    @Injected private var networkService: NetworkService

    typealias Completion<Success> = (Result<Success, ReportError>) -> Void

    enum ReportError: Error {
        case unknown
        case tanConfirmation(NetworkService.DisplayableError)
        case submission(NetworkService.TracingKeysError)
    }

    let diagnosisType: DiagnosisType
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

    func submit(from startDate: Date, untilIncluding endDate: Date, completion: @escaping Completion<Void>) {
        guard let verification = verification else {
            failSilently(completion)
            return
        }

        exposureKeyManager.getKeysForUpload(from: startDate, untilIncluding: endDate) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(temporaryExposureKeys):
                let tracingKeys = TracingKeys(
                    temporaryExposureKeys: temporaryExposureKeys,
                    diagnosisType: self.diagnosisType,
                    verificationPayload: verification
                )
                self.sendTracingKeys(tracingKeys, completion: completion)
            case .failure:
                completion(.failure(.unknown))
            }
        }
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
