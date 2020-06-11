//
//  ExposureKeyManager.swift
//  CoronaContact
//

import ExposureNotification
import Foundation
import Resolver

typealias Completion<T> = (Result<T, Error>) -> Void

class ExposureKeyManager {
    @Injected private var exposureManager: ExposureManager

    func getKeysForUpload(from startDate: Date, untilIncluding endDate: Date, completion: @escaping Completion<[TemporaryExposureKey]>) {
        exposureManager.getDiagnosisKeys { result in
            switch result {
            case let .success(enTemporaryExposureKeys):
                do {
                    let startTime = startDate.startOfDayUTC().timeIntervalSince1970
                    let endTime = endDate.addDays(1)!.startOfDayUTC().timeIntervalSince1970
                    let filteredKeys = enTemporaryExposureKeys.filter { key in
                        let timeStamp = key.rollingStartNumber.timeInterval
                        return startTime <= timeStamp && timeStamp < endTime
                    }

                    let timestamps = filteredKeys.map(\.rollingStartNumber)
                    let passwords = try TracingKeyPassword.getPasswordsFor(timestamps: timestamps)

                    let temporaryExposureKeys = filteredKeys.map { key in
                        TemporaryExposureKey(temporaryExposureKey: key, password: passwords[key.rollingStartNumber])
                    }
                    #if DEBUG
                        LoggingService.debug("---\nUploading Keys:")
                        temporaryExposureKeys.forEach { key in
                            LoggingService.debug("\(key.intervalNumber) \(key.intervalNumber.date)")
                        }
                    #endif

                    completion(.success(temporaryExposureKeys))
                } catch {
                    completion(.failure(error))
                }

            case let .failure(error):
                LoggingService.error("Couldn't get diagnosis keys from the exposure manager: \(error)", context: .exposure)
                completion(.failure(error))
            }
        }
    }
}

#warning("DELETE ME AFTER MERGING OTHER BRANCH INCLUDING THIS")
extension ENIntervalNumber {
    var timeInterval: TimeInterval {
        Double(self) * 60 * 10
    }

    var date: Date {
        Date(timeIntervalSince1970: timeInterval)
    }
}
