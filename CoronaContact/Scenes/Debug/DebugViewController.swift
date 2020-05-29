//
// DebugViewController.swift
// CoronaContact
//

import UIKit
import Reusable
import SwiftRichString
import Resolver

class DebugViewController: UIViewController, StoryboardBased, ViewModelBased, Reusable {
    @Injected private var localStorage: LocalStorage

    var viewModel: DebugViewModel? {
        didSet {
            viewModel?.viewController = self
        }
    }

    @IBAction func close(_ sender: Any) {
        viewModel?.close()
    }

    @IBAction func exposeDiagnosesKeysButtonPressed(_ sender: Any) {
        viewModel?.exposeDiagnosesKeys()
    }

    @IBAction func exposeDiagnosesKeysTestButtonPressed(_ sender: Any) {
        viewModel?.exposeDiagnosesKeys(test: true)
    }

    @IBAction func shareLogButtonTapped(_ sender: Any) {
        viewModel?.shareLog()
    }

    @IBAction func addHandshakeAction(_ sender: Any) {
        viewModel?.addHandShakes()
    }

    @IBAction func addRedInfectionMessage(_ sender: Any) {
        viewModel?.addRedInfectionMessage()
    }

    @IBAction func addYellowInfectionMessage(_ sender: Any) {
        viewModel?.addYellowInfectionMessage()
    }

    @IBAction func scheduleTestNotifications(_ sender: Any) {
        viewModel?.scheduleTestNotifications()
    }

    @IBAction func attestSickness(_ sender: Any) {
        viewModel?.attestSickness()
    }

    @IBAction func isUnderSelfMonitoringTapped(_ sender: Any) {
        localStorage.performedSelfTestAt = Date()
        localStorage.isUnderSelfMonitoring = true
    }

    @IBAction func isProbablySickTapped(_ sender: Any) {
        localStorage.isProbablySickAt = Date()
    }


    @IBAction func resetLogButtonTapped(_ sender: Any) {
        viewModel?.resetLog()
    }

}
