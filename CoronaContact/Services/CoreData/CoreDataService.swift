//
//  CoreDataService.swift
//  CoronaContact
//

import UIKit
import CoreData

class CoreDataService {
    
    public var context: NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        return appDelegate.persistentContainer.viewContext
    }
    
    private let log = ContextLogger(context: .coreData)
        
    func save(completion: () -> Void) {
        
        do {
            try context?.save()
            completion()
        } catch let saveError {
            log.error("Failed to save entity to core data: \(saveError.localizedDescription)")
        }
    }
    
    func getAllEncounters() -> [BaseEncounter] {
        
        guard let context = context else { return [] }
        
        var result: [BaseEncounter] = []
        
        for type in DiaryEntry.allCases {
            
            let fetchRequest = NSFetchRequest<BaseEncounter>(entityName: type.coreDataEncounterEntityName)
            
            do {
                let encounters = try context.fetch(fetchRequest)
                result.append(contentsOf: encounters)
            } catch let fetchError {
                log.error("Error accoured fetching \(type.coreDataEncounterEntityName) - \(fetchError.localizedDescription)")
            }
        }
        
        log.debug("All Encounters: \(result)")
        return result
    }
    
    func deleteDiaryEntry(diaryEntryType: DiaryEntry, selectedId: UUID, completion: () -> Void) {
        
        guard let context = context else { return }
        
        let fetchRequest = NSFetchRequest<BaseEncounter>(entityName: diaryEntryType.coreDataEncounterEntityName)
        let predicate = NSPredicate(format: "cdId == %@", selectedId as CVarArg)
        fetchRequest.predicate = predicate
        
        do {
            let results = try context.fetch(fetchRequest)
            
            if results.isEmpty {
                log.error("There is not entity with the id: \(selectedId)")
            } else if results.count > 1 {
                log.error("There are too many entities with the same id: \(selectedId)")
            } else {
                context.delete(results[0])
                try context.save()
                completion()
            }
        } catch let deleteError {
            log.error("Error accoured deleting: \(deleteError.localizedDescription)")
        }
    }
    
    func deleteDiariesInPast() {
        
        guard let context = context else { return }
        guard let limitDate = Calendar.current.date(byAdding: .day, value: -14, to: Date()) else { return }
        
        for type in DiaryEntry.allCases {
            
            let fetchRequest = NSFetchRequest<BaseEncounter>(entityName: type.coreDataEncounterEntityName)
            let predicate = NSPredicate(format: "cdDate < %@", limitDate as NSDate)
            fetchRequest.predicate = predicate
            
            do {
                let results = try context.fetch(fetchRequest)
                results.forEach({ context.delete($0) })
                try context.save()
                
            } catch let deleteError {
                log.error("Error accoured deleting: \(deleteError.localizedDescription)")
            }
        }
    }
    
    func clear() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let entities = appDelegate.persistentContainer.managedObjectModel.entities
        entities.compactMap({ $0.name }).forEach(clearDeepObjectEntity)
    }
    
    private func clearDeepObjectEntity(_ entity: String) {
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context?.execute(deleteRequest)
            try context?.save()
        } catch let deleteError {
            log.error("Error on deleting entry with name: \(entity). The error was: \(deleteError.localizedDescription)")
        }
    }
}
