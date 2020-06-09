//
//  DebugViewController.swift
//  CoronaContact
//

import Resolver
import Reusable
import SwiftRichString
import UIKit

class DebugViewController: UIViewController, StoryboardBased, ViewModelBased, Reusable {
    @Injected private var localStorage: LocalStorage
    @Injected private var batchDownloadScheduler: BatchDownloadScheduler
    @IBOutlet var batchDownloadSchedulerResultLabel: UILabel!
    @IBOutlet var currentStateLabel: UILabel!
    @IBOutlet var probablySickButton: SecondaryButton!
    @IBOutlet var attestedSickButton: SecondaryButton!
    @IBOutlet var revokeProbablySickButton: SecondaryButton!
    @IBOutlet var revokeAttestedSickButton: SecondaryButton!

    var viewModel: DebugViewModel? {
        didSet {
            viewModel?.viewController = self
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.updateView()
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

    // MARK: - Batch Download

    @IBAction func scheduleBackgroundTask(_ sender: Any) {
        batchDownloadScheduler.scheduleBackgroundTaskForDebuggingPurposes()
    }

    // MARK: - sickness state

    @IBAction func setSelftestedSick(_ sender: Any) {
        viewModel?.probablySickness()
    }

    @IBAction func setAttestedSick(_ sender: Any) {
        viewModel?.attestSickness()
    }

    @IBAction func revokeProbablySickButtonPressed(_ sender: Any) {
        viewModel?.revokeProbablySick()
    }

    @IBAction func revokeAttestedSickButton(_ sender: Any) {
        viewModel?.revokeAttestedSick()
    }

    // MARK: - Mark log settings

    @IBAction func shareLogButtonTapped(_ sender: Any) {
        viewModel?.shareLog()
    }

    @IBAction func resetLogButtonTapped(_ sender: Any) {
        viewModel?.resetLog()
    }
}
