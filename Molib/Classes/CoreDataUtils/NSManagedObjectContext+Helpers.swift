
import Foundation
import CoreData

extension NSManagedObjectContext {

    public var childBackgroundContext: NSManagedObjectContext {
        
        get {
        
            let childContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        
            childContext.parent = self
        
            return childContext
        }
    }
}
