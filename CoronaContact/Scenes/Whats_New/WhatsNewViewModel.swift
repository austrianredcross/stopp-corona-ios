//
//  WhatsNewViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class WhatsNewViewModel {
    @Injected
    private var repository: WhatsNewRepository

    var whatsNewText: String? {
        repository.allHistoryItems.last
    }
}
