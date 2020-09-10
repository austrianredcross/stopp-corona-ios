//
//  MaintenanceTaskRepository.swift
//  CoronaContact
//

import Resolver
import UIKit

class MaintenanceTaskRepository {
    var appInfo: AppInfo = UIApplication.shared
    var maintenanceTasks = AppVersionHistory.maintenanceTasks

    @Persisted(userDefaultsKey: "lastMaintenancePerformed",
               notificationName: .init("lastMaintenancePerformedDidChange"),
               defaultValue: .notPreviouslyInstalled)
    var lastMaintenancePerformed: AppVersion

    @Injected
    private var localStorage: LocalStorage

    var newMaintenanceTasks: [MaintenancePerforming] {
        maintenanceTasks
            .filter { $0.key > lastMaintenancePerformed }
            .sorted(by: ascendingKeys)
            .flatMap(\.value)
    }

    func currentMaintenancePerformed() {
        lastMaintenancePerformed = appInfo.appVersion
    }
}
