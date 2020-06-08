//
//  CompleteOperation.swift
//  CoronaContact
//

import Foundation

class CompleteOperation: AsyncResultOperation<Void, DownloadError> {
    override func main() {
        finish(with: .success(()))
    }

    override func cancel() {
        super.cancel(with: .cancelled)
    }
}
