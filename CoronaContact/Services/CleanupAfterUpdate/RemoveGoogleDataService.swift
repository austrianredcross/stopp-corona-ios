//
//  RemoveGoogleDataService.swift
//  CoronaContact
//

import Foundation

protocol MaintenancePerforming {
    func performMaintenance(completion: (_ success: Bool) -> Void)
}

struct RemoveGoogleDataService: MaintenancePerforming {
    private enum RemovableItem {
        static let googleFolder = "Google"
        static let googleSDKEventsFolder = "google-sdks-events"
        static let firebasePLIST = "com.firebase.FIRInstallations.plist"
    }

    let fileManager: FileManager

    init(fileManager: FileManager = FileManager()) {
        self.fileManager = fileManager
    }

    private var cachesDirectory: URL? {
        url(for: .cachesDirectory)
    }

    private var applicationSupportDirectory: URL? {
        url(for: .applicationSupportDirectory)
    }

    private var preferencesDirectory: URL? {
        url(for: .libraryDirectory)?.appendingPathComponent("Preferences")
    }

    private func url(for directory: FileManager.SearchPathDirectory) -> URL? {
        fileManager.urls(for: directory, in: .userDomainMask)
            // there should be at most one URL since we limited the search to .userDomainMask
            // in any case the URL for the .userDomainMask is documented to be first
            .first
    }

    func performMaintenance(completion: (_ success: Bool) -> Void) {
        [
            cachesDirectory?.appendingPathComponent(RemovableItem.googleSDKEventsFolder),
            applicationSupportDirectory?.appendingPathComponent(RemovableItem.googleFolder),
            preferencesDirectory?.appendingPathComponent(RemovableItem.firebasePLIST),
        ]
        .compactMap { $0 }
        .forEach { url in
            do {
                try fileManager.removeItem(at: url)
            } catch {
                print(error)
            }
        }
        completion(true)
    }
}
