
import Foundation
import CoreData

let kMagicalRecordDefaultBatchSize = 20
let kEntityNameSelector: Selector = Selector("entityName")


extension NSManagedObject {
    
    class var entityName:String {
        get {

            return NSStringFromClass(self).componentsSeparatedByString(".").last!
        }
    }
    
    class func defaultBatchSize() -> Int {
        
        return kMagicalRecordDefaultBatchSize
    }
    
    
    class func  entityDescriptionInContext(context: NSManagedObjectContext) -> NSEntityDescription {
        
        let entityName = self.entityName
        
        return NSEntityDescription.entityForName(entityName, inManagedObjectContext: context)!
    }
    
    
    class func createEntityInContext(context: NSManagedObjectContext) -> NSManagedObject? {
        
        let entityName = self.entityName
        
        let entity: NSManagedObject = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: context)
        
        return entity
    }
    
    func inContext(context: NSManagedObjectContext) -> NSManagedObject? {
        
        var object: NSManagedObject?
        
        do {
            
            object = try context.existingObjectWithID(self.objectID)
        } catch {
            
        }
        
        return object
    }
    
    class func insertInContext(context: NSManagedObjectContext) -> NSManagedObject? {
    
        return createEntityInContext(context)
    }
    
    class func createFetchRequestInContext(context: NSManagedObjectContext) -> NSFetchRequest {
        
        let request = NSFetchRequest()
        
        request.entity = entityDescriptionInContext(context)
    
        return request
    }

    class func truncateAllInContext(context: NSManagedObjectContext) {
        
        let allEntities = self.findAllInContext(context)
        
        if let all = allEntities {
        
            for  obj in all {
            
                obj.deleteInContext(context)
            }
        }

    }
    
    class func deleteAllWithPredicate(searchTerm: NSPredicate, inContext context: NSManagedObjectContext) {
        
        let itemsToDelete = findAllWithPredicate(searchTerm, inContext: context)
        
        if let items = itemsToDelete {
        
            for item in items {
            
                item.deleteInContext(context)
            }
        }
    }
    
    func deleteInContext(context: NSManagedObjectContext) {
        
        context.deleteObject(self)
    }
    
    class func requestAllInContext(context: NSManagedObjectContext) -> NSFetchRequest {
        
        return createFetchRequestInContext(context)
    }
    
    class func requestAllWithPredicate(searchTerm: NSPredicate, inContext context: NSManagedObjectContext) -> NSFetchRequest {
    
        let request = createFetchRequestInContext(context)
    
        request.predicate = searchTerm
    
        return request
    }
    
    class func requestAllWhere(property: String, isEqualTo value: AnyObject, inContext context: NSManagedObjectContext) -> NSFetchRequest {
    
        let request = createFetchRequestInContext(context)
        
        let predicate = NSPredicate(format: "%K = %@", argumentArray: [property, value])

        request.predicate = predicate
    
        return request
    }
    

    class func requestFirstWithPredicate(searchTerm: NSPredicate, inContext context: NSManagedObjectContext) -> NSFetchRequest {

        let request = createFetchRequestInContext(context)
        
        request.predicate = searchTerm
        
        request.fetchLimit = 1
    
        return request
    }
    
    class func requestFirstByAttribute(attribute: String, withValue searchValue: AnyObject, inContext context:NSManagedObjectContext) -> NSFetchRequest {

        let request = requestAllWhere(attribute, isEqualTo: searchValue, inContext:context)

        request.fetchLimit = 1
    
        return request
    }
    
    class func requestAllSortedBy(sortTerm: String, ascending: Bool, inContext context:NSManagedObjectContext) -> NSFetchRequest {

        return requestAllSortedBy(sortTerm, ascending:ascending, withPredicate:nil, inContext:context)
    }
    
    class func requestAllSortedBy(sortTerm: String, ascending: Bool, withPredicate searchTerm: NSPredicate?, inContext context:NSManagedObjectContext) -> NSFetchRequest {

        let request = requestAllInContext(context)

        if let _ = searchTerm {
    
            request.predicate = searchTerm
        }

        request.fetchBatchSize = defaultBatchSize()
        
        let sortTerms = sortTerm.componentsSeparatedByString(",")
        
        let sortDescriptors = sortTerms
            .map {
                
                (key: String) -> NSSortDescriptor in
                
                let components = key.componentsSeparatedByString(":")
                
                let sortKey = components.first
                var ascend = ascending
                
                if components.count > 1 {
                    
                    if let intValue = Int(components.last!) {
                        ascend = Bool(intValue)
                    }
                }
                
                return NSSortDescriptor(key: sortKey!, ascending: ascend)
            }
    
        request.sortDescriptors = sortDescriptors
    
        return request
    }
}


