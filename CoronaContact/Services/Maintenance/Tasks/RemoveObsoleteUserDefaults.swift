//
//  RemoveObsoleteUserDefaults.swift
//  CoronaContact
//

import Foundation

struct RemoveObsoleteUserDefaults: MaintenancePerforming {
    func performMaintenance(completion: (Bool) -> Void) {
        let obsoleteKeys = [
            "last_downloaded_message",
            "not_fresh_installed",
            "tracking_id",
            "hide_microphone_info_dialog",
            "is_probably_sick",
            "has_attested_sickness",
        ]
        obsoleteKeys.forEach(UserDefaults.standard.removeObject(forKey:))
    }
}
