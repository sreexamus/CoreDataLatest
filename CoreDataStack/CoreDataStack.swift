//
//  CoreDataStack.swift
//  CoreDataLatest
//
//  Created by Iragam Reddy, Sreekanth Reddy on 6/8/19.
//  Copyright © 2019 Iragam Reddy, Sreekanth Reddy. All rights reserved.
//

import CoreData


class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    private lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
        return urls[urls.count-1]
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel? = {
        guard let modelURL = Bundle.main.url(forResource: "Community", withExtension: "momd") else {return nil}
        return NSManagedObjectModel(contentsOf: modelURL)
    }()
    
    private lazy var persistenceStoreCoordinator: NSPersistentStoreCoordinator? = {
        
        guard let managedObjectModel = self.managedObjectModel else { return nil }
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("Community")
        
        do {
            let options = [NSMigratePersistentStoresAutomaticallyOption: true]
            
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        }
        catch {
            fatalError("Error adding persistence store")
        }
        
        return coordinator
    }()
    
   private lazy var masterManagedObjectContext: NSManagedObjectContext = {
        var context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        context.persistentStoreCoordinator = self.persistenceStoreCoordinator
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
    
    lazy var mainManagedObjectContext: NSManagedObjectContext = {
        var context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        context.persistentStoreCoordinator = self.persistenceStoreCoordinator
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
    
    func getPrivateManagedObjectContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        context.parent = mainManagedObjectContext
        context.mergePolicy =
        NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
}


extension NSManagedObjectContext  {
    
    func saveRecursively() {
        let savedSuccessfully: Bool
        if hasChanges {
            do {
                try save()
                savedSuccessfully = true
            } catch {
                savedSuccessfully = false
            }
            
            if savedSuccessfully {
                parent?.saveRecursively()
            }
        }
    }
}
