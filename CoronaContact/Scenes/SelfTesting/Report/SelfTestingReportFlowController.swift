//
//  SelfTestingReportFlowController.swift
//  CoronaContact
//

import Foundation
import Resolver

class SelfTestingReportFlowController {

    @Injected private var databaseService: DatabaseService
    @Injected private var networkService: NetworkService
    @Injected private var cryptoService: CryptoService

    enum Flow {
        case personalData
        case tanConfirmation
        case statusReport
        case done
    }

    var flow: Flow = .personalData
    var personalData: PersonalData?
    var tanUUID: String?
    var infectionInfo: InfectionInfo?
    var infectionWarnings: [OutGoingInfectionWarningWithAddressPrefix] = []

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
        guard let personalData = personalData, let tanUUID = tanUUID else {
            return
        }

        infectionWarnings = (try? cryptoService.createInfectionWarnings(type: .yellow).get()) ?? []
        let infectionMessages = infectionWarnings.map { warning in
            UploadInfectionMessage(message: warning.outGoingInfectionWarning.base64encoded, addressPrefix: warning.addressPrefix)
        }

        flow = .statusReport
        infectionInfo = InfectionInfo(uuid: tanUUID, personalData: personalData, infectionMessages: infectionMessages, authorization: tanNumber)
    }

    func submit(completion: @escaping (Result<Void, NetworkService.InfectionInfoError>) -> Void) {
        guard let infectionInfo = infectionInfo else {
            return
        }

        networkService.sendInfectionInfo(infectionInfo) { [weak self] result in
            switch result {
            case .success(let response):
                print(response)
                self?.flow = .done
                self?.saveInfectionMessages()
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func saveInfectionMessages() {
        databaseService.saveOutgoingInfectionWarnings(infectionWarnings.map { $0.outGoingInfectionWarning })
    }
}
