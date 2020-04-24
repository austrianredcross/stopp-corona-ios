//
//  MissingPermissionsViewModel.swift
//  CoronaContact
//

import UIKit

class MissingPermissionsViewModel: ViewModel {
    weak var coordinator: MissingPermissionsCoordinator?

    init(with coordinator: MissingPermissionsCoordinator) {
        self.coordinator = coordinator
    }

    func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: nil)
        }
    }
}
