//
//  CompleteOperation.swift
//  CoronaContact
//

import Foundation

class CompleteOperation: AsyncResultOperation<Void, BatchDownloadError> {
    override func main() {
        finish(with: .success(()))
    }

    override func cancel() {
        super.cancel(with: .cancelled)
    }
}
