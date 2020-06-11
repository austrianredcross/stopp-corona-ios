//
//  RiskCalculationCompleteOperation.swift
//  CoronaContact
//

import Foundation

class RiskCalculationCompleteOperation: AsyncResultOperation<Void, RiskCalculationError> {
    override func main() {
        finish(with: .success(()))
    }

    override func cancel() {
        super.cancel(with: .cancelled)
    }
}
