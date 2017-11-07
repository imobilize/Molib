
import Foundation
import CoreData

extension NSManagedObject {

    //pragma mark - Finding Data
    
    public class func findAllInContext(context: NSManagedObjectContext) -> [NSManagedObject]? {
    
        let request = requestAllInContext(context: context)
        
        return executeFetchRequest(request: request, inContext:context)
    }
    
    
    public class func findAllSortedBy(sortTerm: String, ascending: Bool, inContext context:NSManagedObjectContext) -> [NSManagedObject]? {
    
        let request = requestAllSortedBy(sortTerm: sortTerm, ascending: ascending, inContext: context)
    
        return executeFetchRequest(request: request, inContext:context)
    }
    

    public class func findAllSortedBy(sortTerm: String, ascending: Bool, withPredicate searchTerm:NSPredicate, inContext context:NSManagedObjectContext) -> [NSManagedObject]? {
        
        let request = requestAllSortedBy(sortTerm: sortTerm, ascending:ascending, withPredicate:searchTerm, inContext:context)
    
        return executeFetchRequest(request: request, inContext:context)
    }
    
    
    public class func findAllWithPredicate(searchTerm: NSPredicate, inContext context: NSManagedObjectContext)  -> [NSManagedObject]? {
        
        let request = createFetchRequestInContext(context: context)
        
        request.predicate = searchTerm
    
        return executeFetchRequest(request: request, inContext:context)
    }
    
    public class func findFirstInContext(context:NSManagedObjectContext) -> NSManagedObject? {
        
        let request = createFetchRequestInContext(context: context)
    
        return executeFetchRequestAndReturnFirstObject(request: request, inContext:context)
    }
    
    public class func findFirstByAttribute(attribute: String, withValue searchValue:AnyObject, inContext context:NSManagedObjectContext) -> NSManagedObject? {
        
        let request = requestFirstByAttribute(attribute: attribute, withValue:searchValue, inContext:context)
        
        return executeFetchRequestAndReturnFirstObject(request: request, inContext:context)
    }

    
    public class func findFirstOrderedByAttribute(attribute: String, ascending: Bool, inContext context: NSManagedObjectContext) -> NSManagedObject? {
        
        let request = requestAllSortedBy(sortTerm: attribute, ascending:ascending, inContext:context)

        request.fetchLimit = 1
    
        return executeFetchRequestAndReturnFirstObject(request: request, inContext:context)
    }
    
    public class func findFirstOrCreateByPredicate(searchTerm: NSPredicate, inContext context: NSManagedObjectContext) -> NSManagedObject? {

        let request = createFetchRequestInContext(context: context)

        request.fetchLimit = 1

        request.predicate = searchTerm
        
        var item: NSManagedObject?
        
        let result = executeFetchRequest(request: request, inContext:context)
        
        if (result?.count == 0) {
            
            item = createEntityInContext(context: context)
        } else {
            
            item = result?.first
        }
        
        return item
    }
    
    
    public class func findFirstOrCreateByAttribute(attribute: String, withValue searchValue: AnyObject, inContext context: NSManagedObjectContext) -> NSManagedObject? {

        var result: NSManagedObject? = findFirstByAttribute(attribute: attribute, withValue:searchValue, inContext:context)
    
        if (result == nil) {
        
            result = createEntityInContext(context: context)
            
            result!.setValue(searchValue, forKey:attribute)
        }
        
        return result
    }
    
    public class func findFirstWithPredicate(searchTerm: NSPredicate, inContext context:NSManagedObjectContext) -> NSManagedObject? {
    
        let request = requestFirstWithPredicate(searchTerm: searchTerm, inContext:context)
    
        return executeFetchRequestAndReturnFirstObject(request: request, inContext:context)
    }
    
    public class func findFirstWithPredicate(searchTerm: NSPredicate, sortedBy property: String, ascending: Bool, inContext context:NSManagedObjectContext) -> NSManagedObject? {
        
        let request = requestAllSortedBy(sortTerm: property, ascending:ascending, withPredicate:searchTerm, inContext:context)
    
        return executeFetchRequestAndReturnFirstObject(request: request, inContext:context)
    }
    
    
    public class func findFirstWithPredicate(searchTerm: NSPredicate, andRetrieveAttributes attributes:Array<String>, inContext context:NSManagedObjectContext) -> NSManagedObject? {
        
        let request = createFetchRequestInContext(context: context)
        request.predicate =  searchTerm
        request.propertiesToFetch = attributes
    
        return executeFetchRequestAndReturnFirstObject(request: request, inContext:context)
    }
    
    public class func findByAttribute(attribute: String, withValue searchValue: AnyObject, inContext context:NSManagedObjectContext) -> [NSManagedObject]? {
        
        let request = requestAllWhere(property: attribute, isEqualTo:searchValue, inContext:context)
    
        return executeFetchRequest(request: request, inContext:context)
    }
    
    public class func findByAttribute(attribute: String, withValue searchValue: NSManagedObject, andOrderBy sortTerm:String, ascending: Bool, inContext context:NSManagedObjectContext) -> [NSManagedObject]? {
        
        let searchTerm = NSPredicate(format: "%K = %@", [attribute, searchValue])
        
        let request = requestAllSortedBy(sortTerm: sortTerm, ascending:ascending, withPredicate:searchTerm, inContext:context)
    
        return executeFetchRequest(request: request, inContext:context)
    }
    
    
    //mark: - NSFetchedResultsController helpers
    
    
//    #if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    
    private class func fetchController(request: NSFetchRequest<NSFetchRequestResult>, delegate:NSFetchedResultsControllerDelegate?, useFileCache: Bool, groupedBy groupKeyPath:String?, inContext context:NSManagedObjectContext)-> NSFetchedResultsController<NSFetchRequestResult> {
    
        var cacheName: String? = nil
        
        if useFileCache {
            
            cacheName = String(format: "MagicalRecord-Cache-%@", self.description())
        }
    
        let controller = NSFetchedResultsController(fetchRequest:request, managedObjectContext:context, sectionNameKeyPath:groupKeyPath, cacheName:cacheName)
        controller.delegate = delegate
    
        return controller
    }
    
    public class func fetchAllInContext(context:NSManagedObjectContext) -> NSFetchedResultsController<NSFetchRequestResult> {
        
        let request = requestAllInContext(context: context)
        
        request.sortDescriptors = []
        
        let controller = fetchController(request: request, delegate: nil, useFileCache: false, groupedBy: nil, inContext: context)
        
        _ = performFetch(controller: controller)
        
        return controller
    }

    
    public class func fetchAllWithDelegate(delegate: NSFetchedResultsControllerDelegate, inContext context:NSManagedObjectContext) -> NSFetchedResultsController<NSFetchRequestResult> {
    
        let request = requestAllInContext(context: context)
    
        let controller = fetchController(request: request, delegate: delegate, useFileCache: false, groupedBy: nil, inContext: context)
    
        _ = performFetch(controller: controller)

        return controller
    }
    
    public class func fetchAllGroupedBy(group: String, withPredicate searchTerm:NSPredicate, sortedBy sortTerm:String, ascending: Bool, delegate:NSFetchedResultsControllerDelegate?, inContext context:NSManagedObjectContext) -> NSFetchedResultsController<NSFetchRequestResult> {
    
        let request = requestAllSortedBy(sortTerm: sortTerm, ascending:ascending, withPredicate:searchTerm, inContext:context)
    
        let controller = fetchController(request: request, delegate:delegate, useFileCache:false, groupedBy:group, inContext:context)
    
        _ = performFetch(controller: controller)
    
        return controller
    }

    public class func fetchAllSortedBy(sortTerm: String, ascending: Bool, withPredicate searchTerm:NSPredicate, delegate:NSFetchedResultsControllerDelegate?, inContext context:NSManagedObjectContext) -> NSFetchedResultsController<NSFetchRequestResult> {
        
        let request = requestAllSortedBy(sortTerm: sortTerm, ascending:ascending, withPredicate:searchTerm, inContext:context)
        
        let controller = fetchController(request: request, delegate:delegate, useFileCache:false, groupedBy:nil, inContext:context)
        
        _ = performFetch(controller: controller)
        
        return controller
    }
    
    public class func fetchAllSortedBy(sortTerm: String, ascending: Bool, withPredicate searchTerm:NSPredicate, groupBy groupingKeyPath:String, delegate:NSFetchedResultsControllerDelegate?, inContext context:NSManagedObjectContext) -> NSFetchedResultsController<NSFetchRequestResult> {
    
        return fetchAllGroupedBy(group: groupingKeyPath, withPredicate:searchTerm, sortedBy:sortTerm, ascending:ascending, delegate:delegate, inContext:context)
    }
    
    
    public class func fetchAllSortedBy(sortTerm: String, ascending: Bool, delegate:NSFetchedResultsControllerDelegate?, inContext context:NSManagedObjectContext) -> NSFetchedResultsController<NSFetchRequestResult> {
        
        let request = requestAllSortedBy(sortTerm: sortTerm, ascending: ascending, inContext: context)
        
        let controller = fetchController(request: request, delegate:delegate, useFileCache:false, groupedBy:nil, inContext:context)
        
        _ = performFetch(controller: controller)
        
        return controller
    }
    
    public class func executeFetchRequest(request: NSFetchRequest<NSFetchRequestResult>, inContext context:NSManagedObjectContext) -> [NSManagedObject]? {
        
        var results: [NSManagedObject]?
        
        context.performAndWait { () -> Void in
            
            var error: NSError?
            
            do {
                results = try context.fetch(request) as? [NSManagedObject]
            } catch let error1 as NSError {
                error = error1
                results = nil
            } catch {
                fatalError()
            }
        }

        if (results == nil) {
//    [MagicalRecord handleErrors:error];
        }
    
        return results
    }
    
    private class func executeFetchRequestAndReturnFirstObject(request: NSFetchRequest<NSFetchRequestResult>, inContext context:NSManagedObjectContext) -> NSManagedObject? {
    
        request.fetchLimit = 1
    
        let resultsOptional = executeFetchRequest(request: request, inContext:context)

        if let results = resultsOptional {
            
            if results.count > 0 {
    
                return results.first
            }

        }
    
        return nil
    }


    public class func performFetch(controller: NSFetchedResultsController<NSFetchRequestResult>) -> Bool {

        var error: NSError? = nil

        let success: Bool
        do {
            try controller.performFetch()
            success = true
        } catch let error1 as NSError {
            error = error1
            success = false
        }

        if (!success) {
    
//            [MagicalRecord handleErrors:error];
        }
    
        return success
    }
//    
//    public class func handleErrors(error: NSError ) {
//
//    // If a custom error handler is set, call that
//        if (errorHandlerTarget != nil && errorHandlerAction != nil) {
//            
//    #pragma clang diagnostic push
//    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
//            [errorHandlerTarget performSelector:errorHandlerAction withObject:error];
//    #pragma clang diagnostic pop
//    }
//    else
//    {
//    // Otherwise, fall back to the default error handling
//    [self defaultErrorHandler:error];
//    }
//    }
//    }
//
//    public class func defaultErrorHandler(error: NSError ) {
//    
//    let userInfo = error.userInfo
//    
//    for (NSArray *detailedError in [userInfo allValues]) {
//        
//        if ([detailedError isKindOfClass:[NSArray class]])
//        {
//            for (NSError *e in detailedError)
//            {
//                if ([e respondsToSelector:@selector(userInfo)])
//                {
//                    MRLogError(@"Error Details: %@", [e userInfo]);
//                }
//                else
//                {
//                    MRLogError(@"Error Details: %@", e);
//                }
//            }
//        }
//        else
//        {
//            MRLogError(@"Error: %@", detailedError);
//        }
//    }
//    MRLogError(@"Error Message: %@", [error localizedDescription]);
//    MRLogError(@"Error Domain: %@", [error domain]);
//    MRLogError(@"Recovery Suggestion: %@", [error localizedRecoverySuggestion]);
//}
}
