//
//  DebugAppHistoryViewController.swift
//  CoronaContact
//

#if DEBUG || STAGE
    import Resolver
    import UIKit

    class DebugAppHistoryViewController: UIViewController {
        var appVersionHistory = AppVersionHistory.whatsNew
        var maintenanceHistory = AppVersionHistory.maintenanceTasks

        struct VersionPresentation {
            let version: AppVersion
            var text: String {
                switch version {
                case .notPreviouslyInstalled:
                    return "New install (\"What's New\" never shown)"
                case let version:
                    return version.description
                }
            }
        }

        @Injected private var whatsNewRepository: WhatsNewRepository
        @Injected private var maintenanceRepository: MaintenanceTasksRepository

        private lazy var versions: [VersionPresentation] = {
            var availableVersions = appVersionHistory.versions.union(maintenanceHistory.versions)
            availableVersions.insert(whatsNewRepository.lastWhatsNewShown)
            availableVersions.insert(maintenanceRepository.lastMaintenancePerformed)
            availableVersions.insert(.notPreviouslyInstalled)
            availableVersions.insert("1.2.1")
            return Array(availableVersions)
                .sorted()
                .map(VersionPresentation.init)
        }()

        override func viewDidLoad() {
            super.viewDidLoad()
            title = "v" + whatsNewRepository.currentAppVersion.description
        }
    }

    extension DebugAppHistoryViewController: UITableViewDataSource {
        func numberOfSections(in tableView: UITableView) -> Int {
            1
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            versions.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell()
            let version = versions[indexPath.row]
            if version.version == whatsNewRepository.lastWhatsNewShown {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            cell.textLabel?.text = version.text
            return cell
        }
    }

    extension DebugAppHistoryViewController: UITableViewDelegate {
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let selected = versions[indexPath.row]
            whatsNewRepository.lastWhatsNewShown = selected.version
            maintenanceRepository.lastMaintenancePerformed = selected.version
            tableView.reloadData()
        }
    }
#endif
