//
//  MaintenanceTasksRepository.swift
//  CoronaContact
//

import Resolver
import UIKit

class MaintenanceTasksRepository {
    var appInfo: AppInfo = UIApplication.shared
    var maintenanceTasks = AppVersionHistory.maintenanceTasks

    @Persisted(userDefaultsKey: "lastMaintenancePerformed",
               notificationName: .init("lastMaintenancePerformedDidChange"),
               defaultValue: .notPreviouslyInstalled)
    var lastMaintenancePerformed: AppVersion

    @Injected
    private var localStorage: LocalStorage

    lazy var currentAppVersion: AppVersion = {
        appInfo.appVersion
    }()

    var newMaintenanceTasks: [MaintenancePerforming] {
        maintenanceTasks
            .filter { $0.key > lastMaintenancePerformed }
            .sorted(by: ascendingKeys)
            .flatMap { $0.value }
    }

    func currentMaintenancePerformed() {
        lastMaintenancePerformed = currentAppVersion
    }
}
