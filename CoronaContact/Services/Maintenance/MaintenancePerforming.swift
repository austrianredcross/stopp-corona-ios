//
//  MaintenancePerforming.swift
//  CoronaContact
//

import Foundation

protocol MaintenancePerforming {
    func performMaintenance(completion: (_ success: Bool) -> Void)
}
