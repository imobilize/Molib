
import Foundation
import CoreData

let kMagicalRecordPSCMismatchWillDeleteStore = "kMagicalRecordPSCMismatchWillDeleteStore"
let kMagicalRecordPSCMismatchDidDeleteStore = "kMagicalRecordPSCMismatchDidDeleteStore"
let kMagicalRecordPSCMismatchWillRecreateStore = "kMagicalRecordPSCMismatchWillRecreateStore"
let kMagicalRecordPSCMismatchDidRecreateStore = "kMagicalRecordPSCMismatchDidRecreateStore"
let kMagicalRecordPSCMismatchCouldNotDeleteStore = "kMagicalRecordPSCMismatchCouldNotDeleteStore"
let kMagicalRecordPSCMismatchCouldNotRecreateStore = "kMagicalRecordPSCMismatchCouldNotRecreateStore"

enum CoreDataStackType: Int {
    
    case Default
    case InMemory
}

class CoreDataUtils {

    let kShouldDeletePersistentStoreOnModelMismatch = true
   
    private let modelResource: String
    
    private let sqliteFile: String
    private let storeType: String
    
    class func inMemorySetup(storeName: String) -> CoreDataUtils {
    
        return CoreDataUtils(storeName: storeName, storeType: NSInMemoryStoreType)
    }
    
    class func defaultSetup(storeName: String) -> CoreDataUtils {
    
        return CoreDataUtils(storeName: storeName, storeType: NSSQLiteStoreType)

    }
    
    private init(storeName: String, storeType: String) {
        
        modelResource = storeName
        sqliteFile = modelResource + ".sqlite"
        self.storeType = storeType
    }
    
    // MARK: - Core Data stack
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "iMobilize.TrendiPeople" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] 
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let bundle = NSBundle(forClass: self.dynamicType)
        
        let modelURL =  bundle.URLForResource(self.modelResource, withExtension: "momd")!
        
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {

        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        
        var success = true
        
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(self.sqliteFile)
        
        var error: NSError? = nil
        
        var failureReason = "There was an error creating or loading the application's saved data."
        
        let store:NSPersistentStore?
        do {
            store = try coordinator!.addPersistentStoreWithType(self.storeType, configuration: nil, URL: url, options: nil)
        } catch var error1 as NSError {
            error = error1
            store = nil
        } catch {
            fatalError()
        }
        
        if store == nil {
            
            let isMigrationError = (error!.code == NSPersistentStoreIncompatibleVersionHashError || error!.code == NSMigrationMissingSourceModelError || error!.code == NSMigrationError)
            
            if (error!.domain == NSCocoaErrorDomain && isMigrationError) {
                
                NSNotificationCenter.defaultCenter().postNotificationName(kMagicalRecordPSCMismatchWillDeleteStore, object:nil)
                
                var deleteStoreError: NSError?
                // Could not open the database, so... kill it! (AND WAL bits)
                let rawURL = url.absoluteString
                
                let shmSidecar = NSURL(string: rawURL + "-shm")!
                let walSidecar = NSURL(string:rawURL + "-wal")!
                
                do {
                    try NSFileManager.defaultManager().removeItemAtURL(url)
                } catch var error as NSError {
                    deleteStoreError = error
                } catch {
                    fatalError()
                }
                do {
                    try NSFileManager.defaultManager().removeItemAtURL(shmSidecar)
                } catch _ {
                }
                do {
                    try NSFileManager.defaultManager().removeItemAtURL(walSidecar)
                } catch _ {
                }
                
                print("Removed incompatible model version: %", url.lastPathComponent, terminator: "")
                
                if(deleteStoreError != nil) {
                    
                    let userInfo = ["Error":deleteStoreError!]
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(kMagicalRecordPSCMismatchCouldNotDeleteStore, object:nil, userInfo: userInfo)
                    
                } else {
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(kMagicalRecordPSCMismatchDidDeleteStore, object:nil)
                }
                
                var error: NSError? = nil
                
                NSNotificationCenter.defaultCenter().postNotificationName(kMagicalRecordPSCMismatchWillRecreateStore, object:nil)
                // Try one more time to create the store
                let store:NSPersistentStore?
                do {
                    store = try coordinator!.addPersistentStoreWithType(self.storeType, configuration: nil, URL: url, options: nil)
                } catch var error1 as NSError {
                    error = error1
                    store = nil
                } catch {
                    fatalError()
                }
                
                if (store != nil) {
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(kMagicalRecordPSCMismatchDidRecreateStore, object:nil)
                    
                    success = true
                } else {
                    
                    let userInfo = ["Error":error!]
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(kMagicalRecordPSCMismatchCouldNotRecreateStore, object:nil, userInfo:userInfo)
                }
            }
            
//            success = recoverFromFailureWithCoordinator(coordinator!, withURL: url, error: error!)
//            
//            if success == false {
//                
//                coordinator = nil
//            }
//                        coordinator = nil
//                        // Report any error we got.
//                        var dict = [String: AnyObject]()
//                        dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
//                        dict[NSLocalizedFailureReasonErrorKey] = failureReason
//                        dict[NSUnderlyingErrorKey] = error
//                        error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
//                        // Replace this with code to handle the error appropriately.
//                        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                        NSLog("Unresolved error \(error), \(error!.userInfo)")
//                        abort()
        }
        
        return coordinator
        }()
    
    lazy var mainManagedObjectContext: NSManagedObjectContext? = {
        
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        
        if coordinator == nil {
            return nil
        }
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        
        managedObjectContext.persistentStoreCoordinator = coordinator
        
        return managedObjectContext
        }()
      // MARK: - Core Data Saving support
    
    func saveContext () {
        
        if let moc = self.mainManagedObjectContext {
            
            var error: NSError? = nil
            
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }

    
    func addPersistentStoreToCoordinatorWithURL() -> NSPersistentStoreCoordinator? {
        
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        

        var success = true
        
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(self.sqliteFile)
        
        var error: NSError? = nil
        
        var failureReason = "There was an error creating or loading the application's saved data."
        
        let store:NSPersistentStore?
        do {
            store = try coordinator!.addPersistentStoreWithType(self.storeType, configuration: nil, URL: url, options: nil)
        } catch let error1 as NSError {
            error = error1
            store = nil
        }
            
        if store == nil {
    
            success = recoverFromFailureWithCoordinator(coordinator!, withURL: url, error: error!)
            
            if success == false {
                
                coordinator = nil
            }
//            coordinator = nil
//            // Report any error we got.
//            var dict = [String: AnyObject]()
//            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
//            dict[NSLocalizedFailureReasonErrorKey] = failureReason
//            dict[NSUnderlyingErrorKey] = error
//            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
//            // Replace this with code to handle the error appropriately.
//            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            NSLog("Unresolved error \(error), \(error!.userInfo)")
//            abort()
        }
        
        return coordinator
    }
    
    func recoverFromFailureWithCoordinator(coordinator: NSPersistentStoreCoordinator,  withURL url: NSURL, error: NSError) -> Bool {
        
        var success = false
        
        if (kShouldDeletePersistentStoreOnModelMismatch) {
            
            let isMigrationError = (error.code == NSPersistentStoreIncompatibleVersionHashError || error.code == NSMigrationMissingSourceModelError || error.code == NSMigrationError)
            
            if (error.domain == NSCocoaErrorDomain && isMigrationError) {
                
                NSNotificationCenter.defaultCenter().postNotificationName(kMagicalRecordPSCMismatchWillDeleteStore, object:nil)
                
                var deleteStoreError: NSError?
                // Could not open the database, so... kill it! (AND WAL bits)
                let rawURL = url.absoluteString
                
                let shmSidecar = NSURL(string: rawURL + "-shm")!
                let walSidecar = NSURL(string:rawURL + "-wal")!
                
                do {
                    try NSFileManager.defaultManager().removeItemAtURL(url)
                } catch let error as NSError {
                    deleteStoreError = error
                }
                do {
                    try NSFileManager.defaultManager().removeItemAtURL(shmSidecar)
                } catch _ {
                }
                do {
                    try NSFileManager.defaultManager().removeItemAtURL(walSidecar)
                } catch _ {
                }
                
                print("Removed incompatible model version: %", url.lastPathComponent, terminator: "")
                
                if(deleteStoreError != nil) {
                    
                    let userInfo = ["Error":deleteStoreError!]
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(kMagicalRecordPSCMismatchCouldNotDeleteStore, object:nil, userInfo: userInfo)
                    
                } else {
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(kMagicalRecordPSCMismatchDidDeleteStore, object:nil)
                }
                
                var error: NSError? = nil
                
                NSNotificationCenter.defaultCenter().postNotificationName(kMagicalRecordPSCMismatchWillRecreateStore, object:nil)
                // Try one more time to create the store
                let store:NSPersistentStore?
                do {
                    store = try coordinator.addPersistentStoreWithType(self.storeType, configuration: nil, URL: url, options: nil)
                } catch let error1 as NSError {
                    error = error1
                    store = nil
                }
                
                if (store != nil) {
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(kMagicalRecordPSCMismatchDidRecreateStore, object:nil)
                    
                    success = true
                } else {
                    
                    let userInfo = ["Error":error!]
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(kMagicalRecordPSCMismatchCouldNotRecreateStore, object:nil, userInfo:userInfo)
                }
            }
        }
        
        return success
        
//        [MagicalRecord handleErrors:error];
    }

}