//
//  MainViewController.swift
//  CoronaContact
//

import Lottie
import Resolver
import Reusable
import UIKit

#if DEBUG
    private let additionDebugViews = false // enable to see debug views in the main view
#endif

final class MainViewController: UIViewController, StoryboardBased, ViewModelBased, FlashableScrollIndicators {
    var viewModel: MainViewModel? {
        didSet {
            viewModel?.viewController = self
        }
    }

    var flashScrollIndicatorsAfter: DispatchTimeInterval { .seconds(1) }

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var userHealthWrapperView: UIView!
    @IBOutlet var userHealthStatusView: QuarantineNotificationView!
    @IBOutlet var contactHealthWrapperView: UIView!
    @IBOutlet var contactHealthStatusView: QuarantineNotificationView!
    @IBOutlet var revocationWrapperView: UIView!
    @IBOutlet var revocationStatusView: QuarantineNotificationView!
    @IBOutlet var notificationStackView: UIStackView!
    @IBOutlet var shareAppCardView: ShareAppCardView!
    @IBOutlet var selfTestingStackView: UIStackView!
    @IBOutlet var sicknessCertificateStackView: UIStackView!
    @IBOutlet var automaticHandshakeInactiveView: UIView!
    @IBOutlet var automaticHandshakeActiveView: UIView!
    @IBOutlet var automaticHandshakeAnimationView: AnimationView!
    @IBOutlet var backgroundHandshakeActiveStateLabel: TransLabel!
    @IBOutlet var backgroundHandshakeDescriptionLabel: TransLabel!
    @IBOutlet var handshakePausedInformation: UIView!
    @IBOutlet var backgroundHandshakeStackView: LabelSwitchStackView!
    private weak var launchScreenView: LaunchScreenView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupAccessibility()
        setupLaunchScreen()
        setupAutomatedHandshakeAnimation()
        registerNotificationObserver()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.viewWillAppear()
        updateView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        flashScrollIndicators()
    }

    deinit {
        removeNotificationObserver()
    }
    
    private func setupAccessibility() {
        
        automaticHandshakeAnimationView.isAccessibilityElement = true
        automaticHandshakeAnimationView.accessibilityTraits = .image
        automaticHandshakeAnimationView.accessibilityLabel = "automatic_handshake_img_active".localized
    }

    private func setupLaunchScreen() {
        launchScreenView = LaunchScreenView.loadFromNib()

        if let currentWindow = UIWindow.key {
            currentWindow.embedSubview(launchScreenView)

            Timer.scheduledTimer(withTimeInterval: AppConfiguration.launchScreenDuration, repeats: false) { [weak self] _ in
                self?.launchScreenView.startFadeOutAnimation(withDuration: AppConfiguration.launchScreenFadeOutAnimationDuration)
            }
        }
    }

    private func setupAutomatedHandshakeAnimation() {
        automaticHandshakeAnimationView.loopMode = .loop
        if let path = Bundle.main.path(forResource: "handshakeActive", ofType: "json") {
            automaticHandshakeAnimationView.animation = Animation.filepath(path, animationCache: nil)
        }
    }

    func updateView() {
        guard let viewModel = viewModel, isViewLoaded else { return }

        notificationStackView.isHidden = !viewModel.displayNotifications

        configureUserHealthstatusView()
        configureContactHealthStatusView()
        configureRevocationStatusView()
        configureShareAppCardView()
        configureSelfTestingView()
        configureSicknessCertificateView()
        configureAutomationHandshakeView()
        configureBackgroundHandshakeStackView()
    }

    private func configureUserHealthstatusView() {
        guard let viewModel = viewModel else { return }

        switch viewModel.userHealthStatus {
        case .isHealthy:
            userHealthWrapperView.isHidden = true
            userHealthStatusView.isHidden = true
        default:
            userHealthWrapperView.isHidden = false
            userHealthStatusView.isHidden = false
        }
        userHealthStatusView.indicatorColor = viewModel.userHealthStatus.color
        userHealthStatusView.icon = viewModel.userHealthStatus.icon
        userHealthStatusView.headlineText = viewModel.userHealthStatus.headline
        userHealthStatusView.descriptionText = viewModel.userHealthStatus.description
        userHealthStatusView.quarantineCounter = viewModel.userHealthStatus.quarantineDays

        userHealthStatusView.buttonText = viewModel.userHealthStatus.primaryActionText
        userHealthStatusView.handlePrimaryTap = { [weak self] in
            self?.viewModel?.tappedPrimaryButtonInUserHealthStatus()
        }

        userHealthStatusView.removeButtons()

        if let secondaryActionText = viewModel.userHealthStatus.secondaryActionText {
            userHealthStatusView.addButton(title: secondaryActionText) { [weak self] in
                self?.viewModel?.tappedSecondaryButtonInUserHealthStatus()
            }
        }

        if let tertiaryActionText = viewModel.userHealthStatus.tertiaryActionText {
            userHealthStatusView.addButton(title: tertiaryActionText) { [weak self] in
                self?.viewModel?.tappedTertiaryButtonInUserHealthStatus()
            }
        }

        if viewModel.userHealthStatus.canUploadMissingKeys {
            if case .hasAttestedSickness = viewModel.userHealthStatus {
                userHealthStatusView.addLabel(title: "sickness_certificate_attest_info_update".localized)
                userHealthStatusView.addButton(title: "sickness_certificate_attest_button_update".localized) { [weak self] in
                    self?.viewModel?.uploadMissingAttestedSickKeys()
                }
            }
            if case .isProbablySick = viewModel.userHealthStatus {
                userHealthStatusView.addLabel(title: "self_testing_symptoms_warning_info_update".localized)
                userHealthStatusView.addButton(title: "self_testing_symptoms_warning_button_update".localized) { [weak self] in
                    self?.viewModel?.uploadMissingPobablySickKeys()
                }
            }
        }

        #if DEBUG
            if additionDebugViews {
                let localStorage: LocalStorage = Resolver.resolve()
                if localStorage.attestedSicknessAt != nil {
                    userHealthStatusView.addButton(title: "DEBUG: move back a day") {
                        localStorage.attestedSicknessAt = localStorage.attestedSicknessAt?.addDays(-1)
                        localStorage.missingUploadedKeysAt = localStorage.missingUploadedKeysAt?.addDays(-1)
                    }
                }
                if localStorage.isProbablySickAt != nil {
                    userHealthStatusView.addButton(title: "DEBUG: move back a day") {
                        localStorage.isProbablySickAt = localStorage.isProbablySickAt?.addDays(-1)
                        localStorage.missingUploadedKeysAt = localStorage.missingUploadedKeysAt?.addDays(-1)
                    }
                }
                if localStorage.lastYellowContact != nil {
                    contactHealthStatusView.addButton(title: "DEBUG: yellow back a day") {
                        localStorage.lastYellowContact = localStorage.lastYellowContact?.addDays(-1)
                    }
                }
                if localStorage.lastRedContact != nil {
                    contactHealthStatusView.addButton(title: "DEBUG: red back a day") {
                        localStorage.lastRedContact = localStorage.lastRedContact?.addDays(-1)
                    }
                }
            }
        #endif
    }

    private func configureContactHealthStatusView() {
        if let contactHealthStatus = viewModel?.contactHealthStatus {
            contactHealthWrapperView.isHidden = false
            contactHealthStatusView.isHidden = false
            contactHealthStatusView.indicatorColor = contactHealthStatus.color
            contactHealthStatusView.icon = contactHealthStatus.iconImageNotification
            contactHealthStatusView.headlineText = contactHealthStatus.headlineNotification
            contactHealthStatusView.quarantineCounter = contactHealthStatus.quarantineDays
            contactHealthStatusView.descriptionText = contactHealthStatus.descriptionNotification
            contactHealthStatusView.buttonText = contactHealthStatus.buttonNotification
            contactHealthStatusView.handlePrimaryTap = { [weak self] in
                self?.viewModel?.contactSickness(with: contactHealthStatus)
            }
        } else {
            contactHealthWrapperView.isHidden = true
            contactHealthStatusView.isHidden = true
        }
    }

    private func configureRevocationStatusView() {
        guard let revocationStatus = viewModel?.revocationStatus else {
            revocationWrapperView.isHidden = true
            revocationStatusView.isHidden = true
            return
        }

        revocationWrapperView.isHidden = false
        revocationStatusView.isHidden = false
        revocationStatusView.indicatorColor = revocationStatus.color
        revocationStatusView.icon = revocationStatus.icon
        revocationStatusView.headlineText = revocationStatus.headline
        revocationStatusView.descriptionText = revocationStatus.description
        revocationStatusView.appearance = revocationStatus.notificationAppearance

        if let primaryActionText = revocationStatus.primaryActionText {
            revocationStatusView.buttonText = primaryActionText
        } else {
            revocationStatusView.isPrimaryButtonEnabled = false
        }

        revocationStatusView.closeButton.isHidden = false
        revocationStatusView.handleClose = { [weak self] in
            self?.revocationStatusView.isHidden = true
            self?.viewModel?.removeRevocationStatus()
        }
    }

    private func configureAutomationHandshakeView() {
        guard let viewModel = viewModel else { return }

        if viewModel.isBackgroundHandshakeDisabled == false {
            automaticHandshakeInactiveView.isHidden = true
            automaticHandshakeActiveView.isHidden = false
            automaticHandshakeAnimationView.play()
            backgroundHandshakeStackView.stackViewSwitch.isOn = true
            backgroundHandshakeDescriptionLabel.styledText = "automatic_handshake_description_on".localized
            if viewModel.automaticHandshakePaused {
                handshakePausedInformation.isHidden = false
                backgroundHandshakeActiveStateLabel.styleName = StyleNames.boldYellow.rawValue
                backgroundHandshakeActiveStateLabel.styledText = "automatic_handshake_switch_paused".localized
                backgroundHandshakeStackView.stackViewSwitch.onTintColor = .ccYellow
            } else {
                handshakePausedInformation.isHidden = true
                backgroundHandshakeActiveStateLabel.styleName = StyleNames.boldBlue.rawValue
                backgroundHandshakeActiveStateLabel.styledText = "automatic_handshake_switch_on".localized
                backgroundHandshakeStackView.stackViewSwitch.onTintColor = .ccBlue
            }
        } else {
            handshakePausedInformation.isHidden = true
            automaticHandshakeInactiveView.isHidden = false
            automaticHandshakeActiveView.isHidden = true
            automaticHandshakeAnimationView.pause()
            backgroundHandshakeStackView.stackViewSwitch.isOn = false
            backgroundHandshakeActiveStateLabel.styleName = StyleNames.boldRed.rawValue
            backgroundHandshakeActiveStateLabel.styledText = "automatic_handshake_switch_off".localized
            backgroundHandshakeDescriptionLabel.styledText = "automatic_handshake_description_off".localized
        }

        if viewModel.hasAttestedSickness {
            backgroundHandshakeDescriptionLabel.styledText = "automatic_handshake_description_disabled".localized
        }
    }
    
    private func configureBackgroundHandshakeStackView() {
        
        backgroundHandshakeStackView.switchValueChanged = { [weak self] (value) in
            self?.viewModel?.backgroundDiscovery(enable: value)
        }
    }

    private func configureShareAppCardView() {
        shareAppCardView.handlePrimaryTap = { [weak self] in
            self?.viewModel?.shareApp()
        }
    }

    private func configureSelfTestingView() {
        guard let viewModel = viewModel else { return }

        selfTestingStackView.isHidden = viewModel.isProbablySick || viewModel.hasAttestedSickness
    }

    private func configureSicknessCertificateView() {
        guard let viewModel = viewModel else { return }

        sicknessCertificateStackView.isHidden = viewModel.hasAttestedSickness
    }

    @IBAction func helpTapped(_ sender: Any) {
        viewModel?.help()
    }

    @IBAction func startMenuTapped(_ sender: Any) {
        viewModel?.startMenu()
    }

    @IBAction func selfTestingTapped(_ sender: Any) {
        viewModel?.selfTestingTapped()
    }
    
    @IBAction func coronaSuspicionTapped(_ sender: Any) {
        viewModel?.coronaSuspicionButtonTapped()
    }
    
    @IBAction func sicknessCertificateTapped(_ sender: Any) {
        viewModel?.sicknessCertificateTapped()
    }

    // MARK: - Event Handling

    private func registerNotificationObserver() {
        removeNotificationObserver()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAppWillEnterForegroundNotification(notification:)),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }

    private func removeNotificationObserver() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    @objc func handleAppWillEnterForegroundNotification(notification: Notification) {
        let isOnScreen = isViewLoaded && view.window != nil
        // Runs everytime the app comes into foreground and the dashboard screen is visible
        if isOnScreen {
            viewModel?.viewWillAppear()
        }
    }
}
