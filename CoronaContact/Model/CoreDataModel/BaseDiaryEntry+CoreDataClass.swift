//
//  BaseDiaryEntry+CoreDataClass.swift
//  CoronaContact
//

import Foundation
import CoreData

protocol BaseDiaryInformationDelegate {
    var diaryInformation: BaseDiaryInformation? { get }
}

@objc(BaseDiaryEntry)
public class BaseDiaryEntry: NSManagedObject, BaseDiaryInformationDelegate {
    
    var diaryInformation: BaseDiaryInformation? { return nil }
}
