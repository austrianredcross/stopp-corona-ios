//
//  MicrophoneInfoViewModel.swift
//  CoronaContact
//

import Foundation

class MicrophoneInfoViewModel: ViewModel {
    weak var coordinator: MicrophoneInfoCoordinator?

    init(with coordinator: MicrophoneInfoCoordinator) {
        self.coordinator = coordinator
    }

    func close() {
        coordinator?.close()
    }

    func hideNextTimeCheckboxChanged(isChecked: Bool) {
        UserDefaults.standard.hideMicrophoneInfoDialog = isChecked
    }
}
