//
//  HistoryViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class HistoryViewModel {
    weak var coordinator: HistoryCoordinator?
    weak var viewController: HistoryViewController?
    private var history: [History]?

    @Injected private var dba: DatabaseService

    init(with coordinator: HistoryCoordinator) {
        self.coordinator = coordinator

        dba.getHistoryContacts { [weak self] result in
            if case .success(let history) = result {
                self?.history = history
                self?.viewController?.updateTableView()
            }
        }
    }

    func getHistoryAtIndex(_ row: Int) -> History? {
        history?[row]
    }

    func numberOfHistoryElements() -> Int {
        history?.count ?? 0
    }
}
