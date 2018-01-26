
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

public class CoreDataUtils {

    let kShouldDeletePersistentStoreOnModelMismatch = true
   
    private let modelResource: String
    
    private let sqliteFile: String
    private let storeType: String
    
    public class func inMemorySetup(storeName: String) -> CoreDataUtils {
    
        return CoreDataUtils(storeName: storeName, storeType: NSInMemoryStoreType)
    }
    
    public class func defaultSetup(storeName: String) -> CoreDataUtils {
    
        return CoreDataUtils(storeName: storeName, storeType: NSSQLiteStoreType)

    }
    
    private init(storeName: String, storeType: String) {
        
        modelResource = storeName
        sqliteFile = modelResource + ".sqlite"
        self.storeType = storeType
    }
    
    // MARK: - Core Data stack
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "iMobilize.TrendiPeople" in the application's documents Application Support directory.
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] 
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let bundle = Bundle.main
        
        let modelURL =  bundle.url(forResource: self.modelResource, withExtension: "momd")!
        
        return NSManagedObjectModel(contentsOf: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {

        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        
        var success = true
        
        let url = self.applicationDocumentsDirectory.appendingPathComponent(self.sqliteFile)
        
        var error: Error? = nil
        
        var failureReason = "There was an error creating or loading the application's saved data."
        
        let store:NSPersistentStore?
        do {
            store = try coordinator!.addPersistentStore(ofType: self.storeType, configurationName: nil, at: url, options: nil)
        } catch var error1 {
            error = error1
            store = nil
        }
        
        if store == nil {

            var isMigrationError = false
            var domain = ""

            if let nsError = error as NSError? {
                isMigrationError = (nsError.code == NSPersistentStoreIncompatibleVersionHashError || nsError.code == NSMigrationMissingSourceModelError || nsError.code == NSMigrationError)
                domain = nsError.domain
            }

            if (domain == NSCocoaErrorDomain && isMigrationError) {
                
                var notificationName = NSNotification.Name(rawValue: kMagicalRecordPSCMismatchWillDeleteStore)
                notificationCenter.post(name: notificationName, object:nil)

                var deleteStoreError: Error?
                // Could not open the database, so... kill it! (AND WAL bits)
                let rawURL = url.absoluteString
                
                let shmSidecar = URL(string: rawURL + "-shm")!
                let walSidecar = URL(string:rawURL + "-wal")!
                
                do {
                    try fileManager.removeItem(at: url)
                } catch var error {
                    deleteStoreError = error
                }
                
                do {
                    try fileManager.removeItem(at: shmSidecar)
                } catch _ {
                }
                do {
                    try fileManager.removeItem(at: walSidecar)
                } catch _ {
                }
                
                print("Removed incompatible model version: %", url.lastPathComponent, terminator: "")
                
                if(deleteStoreError != nil) {
                    
                    let userInfo = ["Error":deleteStoreError!]
                    let notificationName = NSNotification.Name(rawValue: kMagicalRecordPSCMismatchCouldNotDeleteStore)
                    notificationCenter.post(name: notificationName, object:nil, userInfo: userInfo)

                } else {
                    let notificationName = NSNotification.Name(rawValue: kMagicalRecordPSCMismatchDidDeleteStore)
                    notificationCenter.post(name: notificationName, object:nil)
                }
                
                var error: Error? = nil
                
                notificationName = NSNotification.Name(rawValue: kMagicalRecordPSCMismatchWillRecreateStore)
                notificationCenter.post(name: notificationName, object:nil)
                // Try one more time to create the store
                let store:NSPersistentStore?
                do {
                    store = try coordinator!.addPersistentStore(ofType: self.storeType, configurationName: nil, at: url, options: nil)
                } catch var error1 {
                    error = error1
                    store = nil
                }
                
                if (store != nil) {

                    let notificationName = NSNotification.Name(rawValue: kMagicalRecordPSCMismatchDidRecreateStore)
                    notificationCenter.post(name: notificationName, object:nil)

                    success = true
                } else {
                    
                    let userInfo = ["Error":error!]
                    let notificationName = NSNotification.Name(rawValue: kMagicalRecordPSCMismatchCouldNotRecreateStore)
                    notificationCenter.post(name: notificationName, object:nil, userInfo: userInfo)
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
//                        error = Error(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
//                        // Replace this with code to handle the error appropriately.
//                        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                        NSLog("Unresolved error \(error), \(error!.userInfo)")
//                        abort()
        }
        
        return coordinator
        }()
    
    public lazy var mainManagedObjectContext: NSManagedObjectContext? = {
        
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        
        if coordinator == nil {
            return nil
        }
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        
        managedObjectContext.persistentStoreCoordinator = coordinator
        
        return managedObjectContext
        }()
      // MARK: - Core Data Saving support
    
    public func saveContext () {
        
        if let moc = self.mainManagedObjectContext {
            
            var error: Error? = nil
            
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    print("Unresolved error \(String(describing: error))")
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
        
        let url = self.applicationDocumentsDirectory.appendingPathComponent(self.sqliteFile)
        
        var error: Error? = nil
        
        var _ = "There was an error creating or loading the application's saved data."
        
        let store:NSPersistentStore?
        do {
            store = try coordinator!.addPersistentStore(ofType: self.storeType, configurationName: nil, at: url, options: nil)
        } catch let error1 {
            error = error1
            store = nil
        }
            
        if store == nil {
    
            success = recoverFromFailureWithCoordinator(coordinator: coordinator!, withURL: url, error: error!)
            
            if success == false {
                
                coordinator = nil
            }
//            coordinator = nil
//            // Report any error we got.
//            var dict = [String: AnyObject]()
//            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
//            dict[NSLocalizedFailureReasonErrorKey] = failureReason
//            dict[NSUnderlyingErrorKey] = error
//            error = Error(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
//            // Replace this with code to handle the error appropriately.
//            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            NSLog("Unresolved error \(error), \(error!.userInfo)")
//            abort()
        }
        
        return coordinator
    }
    
    func recoverFromFailureWithCoordinator(coordinator: NSPersistentStoreCoordinator,  withURL url: URL, error: Error) -> Bool {
        
        var success = false
        
        if (kShouldDeletePersistentStoreOnModelMismatch) {
            var isMigrationError = false
            var domain = ""

            if type(of: error) is NSError.Type {
                let nsError = error as NSError
                isMigrationError = (nsError.code == NSPersistentStoreIncompatibleVersionHashError || nsError.code == NSMigrationMissingSourceModelError || nsError.code == NSMigrationError)
                domain = nsError.domain
            }
            
            if (domain == NSCocoaErrorDomain && isMigrationError) {

                var notificationName = NSNotification.Name(rawValue: kMagicalRecordPSCMismatchWillDeleteStore)
                notificationCenter.post(name: notificationName, object:nil)

                var deleteStoreError: Error?
                // Could not open the database, so... kill it! (AND WAL bits)
                let rawURL = url.absoluteString
                
                let shmSidecar = URL(string: rawURL + "-shm")!
                let walSidecar = URL(string:rawURL + "-wal")!
                
                do {
                    try fileManager.removeItem(at: url)
                } catch let error {
                    deleteStoreError = error
                }
                do {
                    try fileManager.removeItem(at: shmSidecar)
                } catch _ {
                }
                do {
                    try fileManager.removeItem(at: walSidecar)
                } catch _ {
                }
                
                print("Removed incompatible model version: %", url.lastPathComponent , terminator: "")
                
                if(deleteStoreError != nil) {
                    
                    let userInfo = ["Error":deleteStoreError!]
                    
                    let notificationName = NSNotification.Name(rawValue: kMagicalRecordPSCMismatchCouldNotDeleteStore)
                    notificationCenter.post(name: notificationName, object:nil, userInfo: userInfo)
                } else {
                    
                    let notificationName = NSNotification.Name(rawValue: kMagicalRecordPSCMismatchDidDeleteStore)
                    notificationCenter.post(name: notificationName, object:nil)
                }
                
                var error: Error? = nil
                notificationName = NSNotification.Name(rawValue: kMagicalRecordPSCMismatchWillRecreateStore)
                notificationCenter.post(name: notificationName, object:nil)
                // Try one more time to create the store
                let store:NSPersistentStore?
                do {
                    store = try coordinator.addPersistentStore(ofType: self.storeType, configurationName: nil, at: url as URL, options: nil)
                } catch let error1 {
                    error = error1
                    store = nil
                }
                
                if (store != nil) {
                    let notificationName = NSNotification.Name(rawValue: kMagicalRecordPSCMismatchDidRecreateStore)
                    notificationCenter.post(name: notificationName, object:nil)
                    
                    success = true
                } else {
                    
                    let userInfo = ["Error":error!]
                    let notificationName = NSNotification.Name(rawValue: kMagicalRecordPSCMismatchCouldNotRecreateStore)
                    notificationCenter.post(name: notificationName, object: nil, userInfo: userInfo)
                }
            }
        }
        
        return success
        
//        [MagicalRecord handleErrors:error];
    }

    lazy var fileManager: FileManager = {
        return FileManager.`default`
    }()

    lazy var notificationCenter: NotificationCenter = {
        return NotificationCenter.`default`
    }()
}
