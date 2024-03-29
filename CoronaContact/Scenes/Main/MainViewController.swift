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
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var notificationStackView: UIStackView!
    @IBOutlet var userHealthStatusView: QuarantineNotificationView!
    @IBOutlet var contactHealthStatusView: QuarantineNotificationView!
    @IBOutlet var primaryContactHealthStatusView: QuarantineNotificationView!
    @IBOutlet var secondaryContactHealthStatusView: QuarantineNotificationView!
    @IBOutlet var revocationStatusView: QuarantineNotificationView!
    @IBOutlet var sunDownerView: SunDownerNotificationView!
    @IBOutlet var sunDownerWrapperView: UIView!
    @IBOutlet var userHealthWrapperView: UIView!
    @IBOutlet var contactHealthWrapperView: UIView!
    @IBOutlet var revocationWrapperView: UIView!
    @IBOutlet var backgroundHandshakeStackView: RiskAssessmentView!
    @IBOutlet var exposureNotificationErrorView: ExposureNotificationErrorView!
    @IBOutlet var automaticHandshakeInactiveView: UIView!
    @IBOutlet var automaticHandshakeActiveView: UIView!
    @IBOutlet var automaticHandshakeAnimationView: AnimationView!
    @IBOutlet var automaticHandshakeHeadline: TransHeadingLabel!
    @IBOutlet var automaticHandShakeInfoStackView: UIStackView!
    @IBOutlet var shareAppCardView: ShareAppCardView!
    @IBOutlet var selfTestingStackView: UIStackView!
    @IBOutlet var sicknessCertificateStackView: UIStackView!
    @IBOutlet var selfTestingSeparatorLineStackView: UIStackView!
    @IBOutlet var sicknessCertificateSeparatorLineStackView: UIStackView!
    @IBOutlet var riskAssessmentUpdatedAtStackView: UIStackView!

    /* COVID Statistics*/
    @IBOutlet var covidIncidencesTableView: UITableView!
    @IBOutlet var covidIncidencesTableViewContainer: UIStackView!
    @IBOutlet var expandButtonUnderLine: UIView!
    @IBOutlet var covidIncidencesTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var stateImageView: UIImageView!
    @IBOutlet var incidenceComparisonLabel: TransLabel!
    @IBOutlet var agesErrorStackView: UIStackView!
    @IBOutlet var agesIncidenceStackView: UIStackView!
    @IBOutlet weak var agesLoadingView: UIActivityIndicatorView!
    
    var isloaded = false
    
    private weak var launchScreenView: LaunchScreenView!

    var viewModel: MainViewModel? {
        didSet {
            viewModel?.viewController = self
        }
    }

    var flashScrollIndicatorsAfter: DispatchTimeInterval { .seconds(1) }

    var isCovidIncidencesTableViewHidden = false {
        didSet {
            covidIncidencesTableViewContainer.isHidden = isCovidIncidencesTableViewHidden
            expandButtonUnderLine.isHidden = !isCovidIncidencesTableViewHidden
            
            covidIncidencesTableViewContainer.roundedCorners(corners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: .normal)
            covidIncidencesTableViewContainer.layer.borderWidth = isCovidIncidencesTableViewHidden ? 0 : 1
            
            covidIncidencesTableViewContainer.layoutIfNeeded()
            updateView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupAccessibility()
        setupLaunchScreen()
        setupAutomatedHandshakeAnimation()
        registerNotificationObserver()
        
        isCovidIncidencesTableViewHidden = false
        covidIncidencesTableView.dataSource = self
        covidIncidencesTableView.delegate = self
        
        scrollView.delegate = self
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
    }
    
    func reloadAGESView() {
        guard let viewModel = viewModel, isViewLoaded else { return }
        
        stateImageView.image = viewModel.drawMap()
        viewModel.setupIncidences()
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
        configureSunDownerView()
        
        covidIncidencesTableView.reloadData()
        covidIncidencesTableView.layoutIfNeeded()
                
        agesLoadingView.startAnimating()
        
        if viewModel.agesRepository.isDataLoading {
            agesLoadingView.isHidden = false
            agesIncidenceStackView.isHidden = true
            agesErrorStackView.isHidden = true
        } else {
            
            agesLoadingView.stopAnimating()
            
            guard let lastDate = viewModel.agesRepository.lastDate?.shortDayShortMonth,
                  let penultimateDate = viewModel.agesRepository.penultimateDate?.shortDayShortMonth else {
                
                agesIncidenceStackView.isHidden = true
                agesErrorStackView.isHidden = false
                agesLoadingView.isHidden = true
                return
            }
            
            incidenceComparisonLabel.styledText = String(format: "main_covid_statistics_comparison".localized, lastDate, penultimateDate)
            
            covidIncidencesTableViewHeightConstraint.constant = covidIncidencesTableView.contentSize.height
            
            agesLoadingView.isHidden = true
            agesIncidenceStackView.isHidden = false
            agesErrorStackView.isHidden = true
        }
    }
    
    func showError(with error: Error) {
        viewModel?.showError(with: error)
    }
    
    private func configureSunDownerView() {
        guard let viewModel = viewModel else { return }

        if viewModel.hasBeenVisibleSunDowner {
            sunDownerWrapperView.isHidden = false
            sunDownerView.isHidden = false
        } else {
            sunDownerWrapperView.isHidden = true
            sunDownerView.isHidden = true
        }
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
        userHealthStatusView.appearance = viewModel.userHealthStatus.notificationAppearance
        userHealthStatusView.dateText = viewModel.userHealthStatus.dateText
        userHealthStatusView.quarantineCounter = viewModel.userHealthStatus.quarantineDays
        userHealthStatusView.isDateLabelEnabled = !userHealthStatusView.dateText.isEmpty
        
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
                    primaryContactHealthStatusView.addButton(title: "DEBUG: yellow back a day") {
                        localStorage.lastYellowContact = localStorage.lastYellowContact?.addDays(-1)
                    }
                }
                if localStorage.lastRedContact != nil {
                    primaryContactHealthStatusView.addButton(title: "DEBUG: red back a day") {
                        localStorage.lastRedContact = localStorage.lastRedContact?.addDays(-1)
                    }
                }
            }
        #endif
    }

    private func configureContactHealthStatusView() {
        
        guard let hasAttestedSickness = viewModel?.hasAttestedSickness, !hasAttestedSickness else {
            contactHealthWrapperView.isHidden = true
            return
        }
        
        guard let contactHealthStatus = viewModel?.contactHealthStatus else {
            contactHealthWrapperView.isHidden = true
            primaryContactHealthStatusView.isHidden = true
            secondaryContactHealthStatusView.isHidden = true
            return
        }
        
        contactHealthWrapperView.isHidden = false
        primaryContactHealthStatusView.isHidden = false
        
        primaryContactHealthStatusView.indicatorColor = contactHealthStatus.primaryColorNotification
        primaryContactHealthStatusView.icon = contactHealthStatus.iconImageNotification
        primaryContactHealthStatusView.headlineText = contactHealthStatus.primaryHeadlineNotification
        primaryContactHealthStatusView.appearance = contactHealthStatus.notificationAppearance
        primaryContactHealthStatusView.quarantineCounter = contactHealthStatus.quarantineDays
        primaryContactHealthStatusView.descriptionText = contactHealthStatus.primaryDescriptionNotification
        primaryContactHealthStatusView.dateText = contactHealthStatus.primaryDateNotification
        primaryContactHealthStatusView.buttonText = contactHealthStatus.buttonNotification
        primaryContactHealthStatusView.handlePrimaryTap = { [weak self] in
            self?.viewModel?.contactSickness(with: contactHealthStatus)
        }
        
        secondaryContactHealthStatusView.indicatorColor = contactHealthStatus.secondaryColorNotification
        secondaryContactHealthStatusView.icon = contactHealthStatus.iconImageNotification
        secondaryContactHealthStatusView.headlineText = contactHealthStatus.secondaryHeadlineNotification
        secondaryContactHealthStatusView.quarantineCounter = contactHealthStatus.quarantineDays
        secondaryContactHealthStatusView.descriptionText = contactHealthStatus.secondaryDescriptionNotification
        secondaryContactHealthStatusView.isDateLabelEnabled = false
        secondaryContactHealthStatusView.isPrimaryButtonEnabled = false
        
        secondaryContactHealthStatusView.isHidden = !(contactHealthStatus == .mixed())
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
        revocationStatusView.dateText = revocationStatus.finishText
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
        
        if !viewModel.isBackgroundHandshakeDisabled && !viewModel.automaticHandshakePaused {
            
            automaticHandShakeInfoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            viewModel.automaticHandshakeInfoViews.forEach { automaticHandShakeInfoStackView.addArrangedSubview($0) }
            
            if let path = viewModel.handShakeAnimationPath {
                automaticHandshakeAnimationView.animation = Animation.filepath(path, animationCache: nil)
            }
            
            automaticHandshakeHeadline.styleName = viewModel.automaticHandshakeHeadlineStyle
            automaticHandshakeHeadline.text = viewModel.automaticHandshakeHeadlineText
            
            riskAssessmentUpdatedAtStackView.isHidden = false
            automaticHandshakeInactiveView.isHidden = true
            automaticHandshakeActiveView.isHidden = false
            automaticHandshakeAnimationView.play()
            
            exposureNotificationErrorView.isHidden = true
            backgroundHandshakeStackView.stackViewSwitch.isOn = true
            backgroundHandshakeStackView.stackViewSwitch.onTintColor = .ccBlue
            backgroundHandshakeStackView.riskAssessmentCurrentStatusLabel.styleName = StyleNames.boldBlue.rawValue
            backgroundHandshakeStackView.riskAssessmentCurrentStatusLabel.styledText = "automatic_handshake_switch_on".localized
        } else {
            
            riskAssessmentUpdatedAtStackView.isHidden = false
            automaticHandshakeInactiveView.isHidden = false
            automaticHandshakeActiveView.isHidden = true
            automaticHandshakeAnimationView.pause()
            automaticHandshakeHeadline.styleName = StyleNames.automaticHandshakeHeadlineDisable.rawValue
            automaticHandshakeHeadline.text = "automatic_handshake_disabled_info".localized
            
            if viewModel.automaticHandshakePaused {
                exposureNotificationErrorView.isHidden = false
                backgroundHandshakeStackView.stackViewSwitch.isOn = true
                backgroundHandshakeStackView.stackViewSwitch.onTintColor = .ccYellow
                backgroundHandshakeStackView.riskAssessmentCurrentStatusLabel.styleName = StyleNames.boldYellow.rawValue
                backgroundHandshakeStackView.riskAssessmentCurrentStatusLabel.styledText = "automatic_handshake_switch_paused".localized
            } else {
                riskAssessmentUpdatedAtStackView.isHidden = true
                exposureNotificationErrorView.isHidden = true
                backgroundHandshakeStackView.stackViewSwitch.isOn = false
                backgroundHandshakeStackView.stackViewSwitch.onTintColor = .gray
                backgroundHandshakeStackView.riskAssessmentCurrentStatusLabel.styleName = StyleNames.boldRed.rawValue
                backgroundHandshakeStackView.riskAssessmentCurrentStatusLabel.styledText = "automatic_handshake_switch_off".localized
                
            }
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
        selfTestingSeparatorLineStackView.isHidden = viewModel.isProbablySick || viewModel.hasAttestedSickness
    }

    private func configureSicknessCertificateView() {
        guard let viewModel = viewModel else { return }

        sicknessCertificateStackView.isHidden = viewModel.hasAttestedSickness
        sicknessCertificateSeparatorLineStackView.isHidden = viewModel.hasAttestedSickness
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

    @IBAction func diaryFaqTapped(_ sender: Any) {
        viewModel?.diaryFaqTapped()
    }
    
    @IBAction func diaryTapped(_ sender: Any) {
        viewModel?.diaryTapped()
    }
    
    @IBAction func statisticsTapped(_ sender: Any) {
        viewModel?.statistics()
    }
        
    @IBAction func covidIncidenceExpandButtonTapped(_ sender: ExpandButton) {
        isCovidIncidencesTableViewHidden.toggle()
        sender.isCollapsed.toggle()
    }
    
    @IBAction func statisticsLegendTapped(_ sender: Any) {
        viewModel?.showLegend()
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

// MARK: - TableView Delegate
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.incidences.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: IncidenceTableViewCell.identifier, for: indexPath) as? IncidenceTableViewCell else { return UITableViewCell() }

        cell.viewModel = viewModel?.incidences[indexPath.item]
        return cell
    }
}
