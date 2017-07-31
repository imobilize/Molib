
import Foundation
import CoreData

extension NSManagedObjectContext {

    
    public var childBackgroundContext: NSManagedObjectContext {
        
        get {
        
            let childContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        
            childContext.parentContext = self
        
            return childContext
        }
    }
    
}
