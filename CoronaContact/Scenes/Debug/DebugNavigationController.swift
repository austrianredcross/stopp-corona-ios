//
//  DebugNavigationController.swift
//  CoronaContact
//

import UIKit

class DebugNavigationController: UINavigationController {
    weak var coordinator: ApplicationCoordinator?

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        coordinator?.debugView()
    }
}
