//
//  StartMenuViewController.swift
//  CoronaContact
//

import Resolver
import Reusable
import UIKit

final class StartMenuViewController: UIViewController, StoryboardBased, FlashableScrollIndicators {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var versionLabel: UILabel!
    @IBOutlet var hideableFunctionsView: UIStackView!
    @IBOutlet var checkSymptomsView: UIView!
    @IBOutlet var revokeSicknessView: UIView!
    @IBOutlet var reportCoronaSuspiciousView: UIView!
    @IBOutlet var reportPositiveDoctorsDiagnosisView: UIView!

    @Injected private var notificationService: NotificationService

    var viewModel: StartMenuViewModel? {
        didSet {
            viewModel?.viewController = self
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.setHidesBackButton(true, animated: false)
        let versionText = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        versionLabel.text = "Version: \(versionText ?? "unknown")"
        updateView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        flashScrollIndicators()
    }

    @IBAction func closeMenuTapped(_ sender: Any) {
        viewModel?.closeMenu()
    }

    @IBAction func checkSymptomsButtonTapped(_ sender: Any) {
        viewModel?.checkSymptoms()
    }
    
    @IBAction func coronaSuspicionTapped(_ sender: Any) {
        viewModel?.coronaSuspicionButtonTapped()
    }

    @IBAction func reportPositiveDoctorsDiagnosisTapped(_ sender: Any) {
        viewModel?.reportPositiveDoctorsDiagnosis()
    }

    @IBAction func revokeSicknessTapped(_ sender: Any) {
        viewModel?.revokeSickness()
    }

    @IBAction func shareAppTapped(_ sender: Any) {
        viewModel?.shareApp()
    }

    @IBAction func aboutAppTapped(_ sender: Any) {
        viewModel?.aboutApp()
    }

    @IBAction func faqButtonTapped(_ sender: Any) {
        viewModel?.website(.faq)
    }

    @IBAction func websiteButtonTapped(_ sender: Any) {
        viewModel?.website(.homepage)
    }

    @IBAction func savedIDsButtonTapped(_ sender: Any) {
        viewModel?.openSavedIDs()
    }

    @IBAction func openSourceLicensesTapped(_ sender: Any) {
        viewModel?.openSourceLicenses()
    }

    @IBAction func dataPrivacyButtonTapped(_ sender: Any) {
        viewModel?.dataPrivacy()
    }

    @IBAction func imprintButtonTapped(_ sender: Any) {
        viewModel?.imprint()
    }
    
    @IBAction func diaryButtonTapped(_ sender: Any) {
        viewModel?.diary()
    }

    func updateView() {
        guard let viewModel = viewModel else { return }

        hideableFunctionsView.isHidden = viewModel.isFunctionsSectionHidden
        checkSymptomsView.isHidden = !viewModel.isSelfTestFunctionAvailable
        revokeSicknessView.isHidden = !viewModel.canRevokeAttestedSickness
        reportCoronaSuspiciousView.isHidden = !viewModel.isSelfTestFunctionAvailable
    }
}
