//
//  MissingPermissionsViewController.swift
//  CoronaContact
//

import UIKit
import Reusable

struct MissingPermissionsRepresentable {

    let title: String
    let headline: String
    let description: String
    let icon: UIImage
    let iconCaption: String
    let settingsText: String
    let buttonText: String
}

final class MissingPermissionsViewController: UIViewController, StoryboardBased, ViewModelBased {

    @IBOutlet weak var headlineLabel: TransLabel!
    @IBOutlet weak var descriptionLabel: TransLabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var iconCaptionLabel: TransLabel!
    @IBOutlet weak var settingsLabel: TransLabel!
    @IBOutlet weak var button: TransButton!

    var viewModel: MissingPermissionsViewModel?

    private var representation: MissingPermissionsRepresentable!

    override func viewDidLoad() {
        super.viewDidLoad()

        configure(with: representation)
    }

    private func configure(with representation: MissingPermissionsRepresentable) {
        self.representation = representation

        guard isViewLoaded else {
            return
        }

        title = representation.title
        headlineLabel.styledText = representation.headline
        descriptionLabel.styledText = representation.description
        iconImageView.image = representation.icon
        iconCaptionLabel.styledText = representation.iconCaption
        settingsLabel.styledText = representation.settingsText
        button.styledTextNormal = representation.buttonText
    }

    @IBAction func buttonPressed(_ sender: Any) {
        viewModel?.openSettings()
    }
}

extension MissingPermissionsViewController {

    static var bluetooth: MissingPermissionsViewController {
        let viewController = instantiate()
        let representation = MissingPermissionsRepresentable(
            title: "missing_permissions_bluetooth_title".localized,
            headline: "missing_permissions_bluetooth_headline".localized,
            description: "missing_permissions_bluetooth_description".localized,
            icon: UIImage(named: "bluetoothIcon")!,
            iconCaption: "missing_permissions_bluetooth_icon_caption".localized,
            settingsText: "missing_permissions_bluetooth_settings".localized,
            buttonText: "missing_permissions_bluetooth_button".localized
        )
        viewController.configure(with: representation)

        return viewController
    }

    static var backgroundAppRefresh: MissingPermissionsViewController {
        let viewController = instantiate()
        let representation = MissingPermissionsRepresentable(
            title: "missing_permissions_background_app_refresh_title".localized,
            headline: "missing_permissions_background_app_refresh_headline".localized,
            description: "missing_permissions_background_app_refresh_description".localized,
            icon: UIImage(named: "backgroundAppRefreshIcon")!,
            iconCaption: "missing_permissions_background_app_refresh_icon_caption".localized,
            settingsText: "missing_permissions_background_app_refresh_settings".localized,
            buttonText: "missing_permissions_background_app_refresh_button".localized
        )
        viewController.configure(with: representation)

        return viewController
    }

    static var exposureFramework: MissingPermissionsViewController {
        let viewController = instantiate()
        let representation = MissingPermissionsRepresentable(
            title: "missing_permissions_background_app_refresh_title".localized,
            headline: "missing_permissions_background_app_refresh_headline".localized,
            description: "missing_permissions_background_app_refresh_description".localized,
            icon: UIImage(named: "covid19Icon")!,
            iconCaption: "missing_permissions_exposure_framework_icon_caption".localized,
            settingsText: "missing_permissions_background_app_refresh_settings".localized,
            buttonText: "missing_permissions_background_app_refresh_button".localized
        )
        viewController.configure(with: representation)

        return viewController
    }
}
