//
//  ReportHealthStatusFlowController.swift
//  CoronaContact
//

import Foundation
import Resolver
import ExposureNotification

class ReportHealthStatusFlowController {

    @Injected private var exposureManager: ExposureManager
    @Injected private var networkService: NetworkService

    enum Flow {
        case personalData
        case tanConfirmation
        case statusReport
        case done
    }

    private let diagnosisType: DiagnosisType
    private var flow: Flow = .personalData
    private var tanUUID: String?
    private var tracingKeys: TracingKeys?
    var personalData: PersonalData?

    init(diagnosisType: DiagnosisType) {
        self.diagnosisType = diagnosisType
    }

    func tanConfirmation(personalData: PersonalData, completion: @escaping (Result<Void, NetworkService.DisplayableError>) -> Void) {
        self.personalData = personalData

        networkService.requestTan(mobileNumber: personalData.mobileNumber) { [weak self] result in
            switch result {
            case .success(let response):
                self?.tanUUID = response.uuid
                self?.flow = .tanConfirmation
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func statusReport(tanNumber: String) {
        guard let tanUUID = tanUUID else {
            return
        }

        let verfication = Verification(uuid: tanUUID, authorization: tanNumber)

        exposureManager.getDiagnosisKeys { [weak self] result in
            switch result {
            case .success(let temporaryExposureKeys):
                self?.flow = .statusReport
                self?.parseTemporaryExposureKeys(temporaryExposureKeys, verification: verfication)
            case .failure(let error):
                LoggingService.error("Couldn't get diagnosis keys from the exposure manager: \(error)", context: .exposure)
            }
        }
    }

    private func parseTemporaryExposureKeys(_ temporaryExposureKeys: [ENTemporaryExposureKey],
                                            verification: Verification) {
        let temporaryExposureKeys = temporaryExposureKeys.map(TemporaryExposureKey.init)
        tracingKeys = TracingKeys(
            temporaryExposureKeys: temporaryExposureKeys,
            diagnosisType: diagnosisType,
            verificationPayload: verification
        )
    }

    func submit(completion: @escaping (Result<Void, NetworkService.TracingKeysError>) -> Void) {
        guard let tracingKeys = tracingKeys else {
            return
        }

        networkService.sendTracingKeys(tracingKeys) { [weak self] result in
            switch result {
            case .success(let response):
                print(response)
                self?.flow = .done
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
