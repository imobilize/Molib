
import Foundation
import CoreData

let kMagicalRecordDefaultBatchSize = 20000


extension NSManagedObject {

    static var kEntityNameSelector: Selector = {
        return #selector(getter: NSFetchRequest<NSFetchRequestResult>.entityName)
    }()

    class var entityName:String {
        get {

            return NSStringFromClass(self).components(separatedBy: ".").last!
        }
    }
    
    class func defaultBatchSize() -> Int {
        
        return kMagicalRecordDefaultBatchSize
    }
    
    
    class func  entityDescriptionInContext(context: NSManagedObjectContext) -> NSEntityDescription {
        
        let entityName = self.entityName
        
        return NSEntityDescription.entity(forEntityName: entityName, in: context)!
    }
    
    
    class func createEntityInContext(context: NSManagedObjectContext) -> NSManagedObject? {
        
        let entityName = self.entityName
        
        let entity: NSManagedObject = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
        
        return entity
    }
    
    public func inContext(context: NSManagedObjectContext) -> NSManagedObject? {
        
        var object: NSManagedObject?
        
        do {
            
            object = try context.existingObject(with: self.objectID)
        } catch {
            
        }
        
        return object
    }
    
    public class func insertInContext(context: NSManagedObjectContext) -> NSManagedObject? {
    
        return createEntityInContext(context: context)
    }
    
    public class func createFetchRequestInContext(context: NSManagedObjectContext) -> NSFetchRequest<NSFetchRequestResult> {
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        
        request.entity = entityDescriptionInContext(context: context)
    
        return request
    }

    public class func truncateAllInContext(context: NSManagedObjectContext) {
        
        let allEntities = self.findAllInContext(context: context)
        
        if let all = allEntities {
        
            for  obj in all {
            
                obj.deleteInContext(context: context)
            }
        }

    }
    
    public class func deleteAllWithPredicate(searchTerm: NSPredicate, inContext context: NSManagedObjectContext) {
        
        let itemsToDelete = findAllWithPredicate(searchTerm: searchTerm, inContext: context)
        
        if let items = itemsToDelete {
        
            for item in items {
            
                item.deleteInContext(context: context)
            }
        }
    }
    
    public func deleteInContext(context: NSManagedObjectContext) {
        
        context.delete(self)
    }
    
    public class func requestAllInContext(context: NSManagedObjectContext) -> NSFetchRequest<NSFetchRequestResult> {
        
        return createFetchRequestInContext(context: context)
    }
    
    public class func requestAllWithPredicate(searchTerm: NSPredicate, inContext context: NSManagedObjectContext) -> NSFetchRequest<NSFetchRequestResult> {
    
        let request = createFetchRequestInContext(context: context)
    
        request.predicate = searchTerm
    
        return request
    }
    
    public class func requestAllWhere(property: String, isEqualTo value: AnyObject, inContext context: NSManagedObjectContext) -> NSFetchRequest<NSFetchRequestResult> {
    
        let request = createFetchRequestInContext(context: context)
        
        let predicate = NSPredicate(format: "%K = %@", argumentArray: [property, value])

        request.predicate = predicate
    
        return request
    }
    

    public class func requestFirstWithPredicate(searchTerm: NSPredicate, inContext context: NSManagedObjectContext) -> NSFetchRequest<NSFetchRequestResult> {

        let request = createFetchRequestInContext(context: context)
        
        request.predicate = searchTerm
        
        request.fetchLimit = 1
    
        return request
    }
    
    public class func requestFirstByAttribute(attribute: String, withValue searchValue: AnyObject, inContext context:NSManagedObjectContext) -> NSFetchRequest<NSFetchRequestResult> {

        let request = requestAllWhere(property: attribute, isEqualTo: searchValue, inContext:context)

        request.fetchLimit = 1
    
        return request
    }
    
    public class func requestAllSortedBy(sortTerm: String, ascending: Bool, inContext context:NSManagedObjectContext) -> NSFetchRequest<NSFetchRequestResult> {

        return requestAllSortedBy(sortTerm: sortTerm, ascending:ascending, withPredicate:nil, inContext:context)
    }
    
    public class func requestAllSortedBy(sortTerm: String, ascending: Bool, withPredicate searchTerm: NSPredicate?, inContext context:NSManagedObjectContext) -> NSFetchRequest<NSFetchRequestResult> {

        let request = requestAllInContext(context: context)

        if let _ = searchTerm {
    
            request.predicate = searchTerm
        }

        request.fetchBatchSize = defaultBatchSize()
        
        let sortTerms = sortTerm.components(separatedBy: ",")
        
        let sortDescriptors = sortTerms
            .map {
                
                (key: String) -> NSSortDescriptor in
                
                let components = key.components(separatedBy: ":")
                
                let sortKey = components.first
                var ascend = ascending
                
                if components.count > 1 {
                    
                    if let intValue = Int(components.last!) {
                        ascend = NSNumber(value: intValue).boolValue
                    }
                }
                
                return NSSortDescriptor(key: sortKey!, ascending: ascend)
            }
    
        request.sortDescriptors = sortDescriptors
    
        return request
    }
}


