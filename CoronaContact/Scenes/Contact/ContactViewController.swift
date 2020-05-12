//
//  MainViewController.swift
//  CoronaContact
//

import Reusable
import UIKit
import Lottie

final class ContactViewController: UIViewController, StoryboardBased, ViewModelBased, FlashableScrollIndicators {

    private enum TableHeaderRow: Int, CaseIterable {
        case ownIdentifier
        case selectAll

        static var count: Int {
            Self.allCases.count
        }
    }

    private enum Section: Int, CaseIterable {
        case header
        case contacts

        static var count: Int {
            Self.allCases.count
        }
    }

    var viewModel: ContactViewModel? {
        didSet {
            viewModel?.viewController = self
        }
    }

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contactListTableView: UITableView?
    @IBOutlet weak var contactListTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var saveButton: PrimaryButton?
    @IBOutlet weak var headStackView: BackgroundStackView?
    @IBOutlet weak var contactStackView: UIStackView?
    @IBOutlet weak var permissionStackView: UIStackView?
    @IBOutlet weak var nearbyPermissionStackView: UIStackView?
    @IBOutlet weak var otherPermissionsStackView: UIStackView?
    @IBOutlet weak var labelMicrofonPermissions: UILabel?
    @IBOutlet weak var labelBluetoothPermissions: UILabel?
    @IBOutlet weak var roundedTopRectsView: SelectedRoundCornersView!
    @IBOutlet weak var microphoneIconImageView: UIImageView!
    @IBOutlet weak var bottomView: UIView?
    @IBOutlet weak var lottieView: AnimationView!

    override func viewDidLoad() {
        super.viewDidLoad()

        roundedTopRectsView.roundCorners(corners: [.topLeft, .topRight], radius: 8)
        contactListTableView?.register(cellType: ContactLabelTableViewCell.self)
        contactListTableView?.register(cellType: ContactTableViewCell.self)
        lottieView.loopMode = .loop
        if let path = Bundle.main.path(forResource: "wave", ofType: "json") {
            lottieView.animation = Animation.filepath(path, animationCache: nil)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.viewOpening()
        lottieView?.play()
        navigationItem.title = "contact_title".localized
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        flashScrollIndicators()
    }

    func updateView() {
        guard let viewModel = viewModel else { return }
        let errors = viewModel.errors
        contactStackView?.isHidden = errors.any
        headStackView?.isHidden = errors.any
        bottomView?.isHidden = errors.any
        permissionStackView?.isHidden = !errors.any
        if errors.any {
            nearbyPermissionStackView?.isHidden = true
            otherPermissionsStackView?.isHidden = !(errors.bluetooth || errors.microphone)
            labelMicrofonPermissions?.isHidden = !errors.microphone
            labelBluetoothPermissions?.isHidden = !errors.bluetooth
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel?.viewClosing()
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            viewModel?.viewClosed()
        }
    }

    func updateContactList(_ contacts: [RemoteContact]) {
        contactListTableView?.reloadData()
        saveButton?.isEnabled = contacts.contains { $0.selected }
    }

    @IBAction func nearbyPermissionGrantedPressed(_ sender: Any) {
        viewModel?.nearbyPermissionGranted()
    }

    @IBAction func openSettingsPressed(_ sender: Any) {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: nil)
        }
    }

    @IBAction func saveButtonPressed(_ sender: Any) {
        viewModel?.saveContacts()
    }

    @IBAction func helpButtonPressed(_ sender: Any) {
        viewModel?.showHelp()
    }

    @IBAction func shareAppButtonPressed(_ sender: Any) {
        viewModel?.shareApp()
    }
}

extension ContactViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = .white
        } else {
            cell.backgroundColor = .ccWhite
        }
    }
}

extension ContactViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let cell = tableView.cellForRow(at: indexPath) as? ContactTableViewCell else {
            return nil
        }

        switch (Section(rawValue: indexPath.section), indexPath.row) {
        case (.header, TableHeaderRow.selectAll.rawValue):
            cell.checkboxView.toggleCheckState(true)
            viewModel?.toggleAllContacts(isSelected: cell.isChecked)
        case (.contacts, _) where cell.isEnabled:
            viewModel?.toggleContactAtIndex(indexPath.row)
        default:
            break
        }

        return nil
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        Section.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let contactRows = viewModel?.numberOfContacts() ?? 0
        let totalVisibleRows = contactRows + TableHeaderRow.count
        contactListTableViewHeightConstraint.constant = (contactListTableView?.rowHeight ?? 0) * CGFloat(
                totalVisibleRows)

        switch Section(rawValue: section) {
        case .header:
            return TableHeaderRow.count
        case .contacts:
            return contactRows
        default:
            assertionFailure("Unsupported section \(section) in table view: \(tableView)")
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section) {
        case .header:
            return configureHeaderCell(tableView, cellForRowAt: indexPath)
        case .contacts:
            return configureContactCell(tableView, cellForRowAt: indexPath)
        default:
            assertionFailure("Unsupported section \(indexPath.section) in table view: \(tableView)")
            return UITableViewCell()
        }
    }

    func configureHeaderCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch TableHeaderRow(rawValue: indexPath.row) {
        case .ownIdentifier:
            guard let viewModel = viewModel else { return UITableViewCell() }

            let cell = tableView.dequeueReusableCell(for: indexPath) as ContactLabelTableViewCell
            let remoteId = viewModel.formatContactName(viewModel.ownRemoteId)
            cell.label.styledText = String(format: "contact_your_id".localized, remoteId)
            return cell
        case .selectAll:
            let cell = tableView.dequeueReusableCell(for: indexPath) as ContactTableViewCell
            cell.configureCell(withText: "contact_table_all".localized)

            return cell
        default:
            assertionFailure("Unsupported table header \(indexPath.row) in table view: \(tableView)")
            return UITableViewCell()
        }
    }

    func configureContactCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel else { return UITableViewCell() }

        let cell = tableView.dequeueReusableCell(for: indexPath) as ContactTableViewCell
        let contact = viewModel.getContactAtIndex(indexPath.row)
        cell.configureCell(contact, viewModel: viewModel)
        return cell
    }
}
