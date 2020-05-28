//
//  SavedIDsViewModel.swift
//  CoronaContact
//

import UIKit

class SavedIDsViewModel: ViewModel {
    weak var coordinator: SavedIDsCoordinator?

    init(_ coordinator: SavedIDsCoordinator) {
        self.coordinator = coordinator
    }

    func deleteExposureLog() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            assertionFailure()
            return
        }
        let app = UIApplication.shared
        if app.canOpenURL(settingsURL) {
            app.open(settingsURL, options: [:], completionHandler: nil)
        }
    }

    func finish() {
        coordinator?.finish(animated: true)
    }
}
