//
//  CoreDataFetch.swift
//  TrendiPeople
//
//  Created by Andre Barrett on 03/08/2015.
//  Copyright (c) 2015 Andre Barrett. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {

    //pragma mark - Finding Data
    
    class func findAllInContext(context: NSManagedObjectContext) -> [NSManagedObject]? {
    
        let request = requestAllInContext(context)
        
        return executeFetchRequest(request, inContext:context)
    }
    
    
    class func findAllSortedBy(sortTerm: String, ascending: Bool, inContext context:NSManagedObjectContext) -> [NSManagedObject]? {
    
        let request = requestAllSortedBy(sortTerm, ascending: ascending, inContext: context)
    
        return executeFetchRequest(request, inContext:context)
    }
    

    class func findAllSortedBy(sortTerm: String, ascending: Bool, withPredicate searchTerm:NSPredicate, inContext context:NSManagedObjectContext) -> [NSManagedObject]? {
        
        let request = requestAllSortedBy(sortTerm, ascending:ascending, withPredicate:searchTerm, inContext:context)
    
        return executeFetchRequest(request, inContext:context)
    }
    
    
    class func findAllWithPredicate(searchTerm: NSPredicate, inContext context: NSManagedObjectContext)  -> [NSManagedObject]? {
        
        let request = createFetchRequestInContext(context)
        
        request.predicate = searchTerm
    
        return executeFetchRequest(request, inContext:context)
    }
    
    class func findFirstInContext(context:NSManagedObjectContext) -> NSManagedObject? {
        
        let request = createFetchRequestInContext(context)
    
        return executeFetchRequestAndReturnFirstObject(request, inContext:context)
    }
    
    class func findFirstByAttribute(attribute: String, withValue searchValue:AnyObject, inContext context:NSManagedObjectContext) -> NSManagedObject? {
        
        let request = requestFirstByAttribute(attribute, withValue:searchValue, inContext:context)
        
        return executeFetchRequestAndReturnFirstObject(request, inContext:context)
    }

    
    class func findFirstOrderedByAttribute(attribute: String, ascending: Bool, inContext context: NSManagedObjectContext) -> NSManagedObject? {
        
        let request = requestAllSortedBy(attribute, ascending:ascending, inContext:context)

        request.fetchLimit = 1
    
        return executeFetchRequestAndReturnFirstObject(request, inContext:context)
    }
    
    class func findFirstOrCreateByPredicate(searchTerm: NSPredicate, inContext context: NSManagedObjectContext) -> NSManagedObject? {

        let request = createFetchRequestInContext(context)

        request.fetchLimit = 1

        request.predicate = searchTerm
        
        var item: NSManagedObject?
        
        let result = executeFetchRequest(request, inContext:context)
        
        if (result?.count == 0) {
            
            item = createEntityInContext(context)
        } else {
            
            item = result?.first
        }
        
        return item
    }
    
    
    class func findFirstOrCreateByAttribute(attribute: String, withValue searchValue: AnyObject, inContext context: NSManagedObjectContext) -> NSManagedObject? {

        var result: NSManagedObject? = findFirstByAttribute(attribute, withValue:searchValue, inContext:context)
    
        if (result == nil) {
        
            result = createEntityInContext(context)
            
            result!.setValue(searchValue, forKey:attribute)
        }
        
        return result
    }
    
    class func findFirstWithPredicate(searchTerm: NSPredicate, inContext context:NSManagedObjectContext) -> NSManagedObject? {
    
        let request = requestFirstWithPredicate(searchTerm, inContext:context)
    
        return executeFetchRequestAndReturnFirstObject(request, inContext:context)
    }
    
    class func findFirstWithPredicate(searchTerm: NSPredicate, sortedBy property: String, ascending: Bool, inContext context:NSManagedObjectContext) -> NSManagedObject? {
        
        let request = requestAllSortedBy(property, ascending:ascending, withPredicate:searchTerm, inContext:context)
    
        return executeFetchRequestAndReturnFirstObject(request, inContext:context)
    }
    
    
    class func findFirstWithPredicate(searchTerm: NSPredicate, andRetrieveAttributes attributes:Array<String>, inContext context:NSManagedObjectContext) -> NSManagedObject? {
        
        let request = createFetchRequestInContext(context)
        request.predicate =  searchTerm
        request.propertiesToFetch = attributes
    
        return executeFetchRequestAndReturnFirstObject(request, inContext:context)
    }
    
    class func findByAttribute(attribute: String, withValue searchValue: AnyObject, inContext context:NSManagedObjectContext) -> [NSManagedObject]? {
        
        let request = requestAllWhere(attribute, isEqualTo:searchValue, inContext:context)
    
        return executeFetchRequest(request, inContext:context)
    }
    
    class func findByAttribute(attribute: String, withValue searchValue: NSManagedObject, andOrderBy sortTerm:String, ascending: Bool, inContext context:NSManagedObjectContext) -> [NSManagedObject]? {
        
        let searchTerm = NSPredicate(format: "%K = %@", [attribute, searchValue])
        
        let request = requestAllSortedBy(sortTerm, ascending:ascending, withPredicate:searchTerm, inContext:context)
    
        return executeFetchRequest(request, inContext:context)
    }
    
    
    //mark: - NSFetchedResultsController helpers
    
    
//    #if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    
    private class func fetchController(request: NSFetchRequest, delegate:NSFetchedResultsControllerDelegate?, useFileCache: Bool, groupedBy groupKeyPath:String?, inContext context:NSManagedObjectContext)-> NSFetchedResultsController {
    
        var cacheName: String? = nil
        
        if useFileCache {
            
            cacheName = String(format: "MagicalRecord-Cache-%@", self.description())
        }
    
        let controller = NSFetchedResultsController(fetchRequest:request, managedObjectContext:context, sectionNameKeyPath:groupKeyPath, cacheName:cacheName)
        controller.delegate = delegate
    
        return controller
    }
    
    class func fetchAllInContext(context:NSManagedObjectContext) -> NSFetchedResultsController {
        
        let request = requestAllInContext(context)
        
        request.sortDescriptors = []
        
        let controller = fetchController(request, delegate: nil, useFileCache: false, groupedBy: nil, inContext: context)
        
        performFetch(controller)
        
        return controller
    }

    
    class func fetchAllWithDelegate(delegate: NSFetchedResultsControllerDelegate, inContext context:NSManagedObjectContext) -> NSFetchedResultsController {
    
        let request = requestAllInContext(context)
    
        let controller = fetchController(request, delegate: delegate, useFileCache: false, groupedBy: nil, inContext: context)
    
        performFetch(controller)

        return controller
    }
    
    class func fetchAllGroupedBy(group: String, withPredicate searchTerm:NSPredicate, sortedBy sortTerm:String, ascending: Bool, delegate:NSFetchedResultsControllerDelegate?, inContext context:NSManagedObjectContext) -> NSFetchedResultsController {
    
        let request = requestAllSortedBy(sortTerm, ascending:ascending, withPredicate:searchTerm, inContext:context)
    
        let controller = fetchController(request, delegate:delegate, useFileCache:false, groupedBy:group, inContext:context)
    
        performFetch(controller)
    
        return controller
    }

    class func fetchAllSortedBy(sortTerm: String, ascending: Bool, withPredicate searchTerm:NSPredicate, delegate:NSFetchedResultsControllerDelegate?, inContext context:NSManagedObjectContext) -> NSFetchedResultsController {
        
        let request = requestAllSortedBy(sortTerm, ascending:ascending, withPredicate:searchTerm, inContext:context)
        
        let controller = fetchController(request, delegate:delegate, useFileCache:false, groupedBy:nil, inContext:context)
        
        performFetch(controller)
        
        return controller
    }
    
    class func fetchAllSortedBy(sortTerm: String, ascending: Bool, withPredicate searchTerm:NSPredicate, groupBy groupingKeyPath:String, delegate:NSFetchedResultsControllerDelegate?, inContext context:NSManagedObjectContext) -> NSFetchedResultsController {
    
        return fetchAllGroupedBy(groupingKeyPath, withPredicate:searchTerm, sortedBy:sortTerm, ascending:ascending, delegate:delegate, inContext:context)
    }
    
    
    class func fetchAllSortedBy(sortTerm: String, ascending: Bool, delegate:NSFetchedResultsControllerDelegate?, inContext context:NSManagedObjectContext) -> NSFetchedResultsController {
        
        let request = requestAllSortedBy(sortTerm, ascending: ascending, inContext: context)
        
        let controller = fetchController(request, delegate:delegate, useFileCache:false, groupedBy:nil, inContext:context)
        
        performFetch(controller)
        
        return controller
    }
    
    class func executeFetchRequest(request: NSFetchRequest, inContext context:NSManagedObjectContext) -> [NSManagedObject]? {
        
        var results: [NSManagedObject]?
        
        context.performBlockAndWait { () -> Void in
            
            var error: NSError?
            
            do {
                results = try context.executeFetchRequest(request) as? [NSManagedObject]
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
    
    private class func executeFetchRequestAndReturnFirstObject(request: NSFetchRequest, inContext context:NSManagedObjectContext) -> NSManagedObject? {
    
        request.fetchLimit = 1
    
        let resultsOptional = executeFetchRequest(request, inContext:context)

        if let results = resultsOptional {
            
            if results.count > 0 {
    
                return results.first
            }

        }
    
        return nil
    }


    class func performFetch(controller: NSFetchedResultsController) -> Bool {

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
//    class func handleErrors(error: NSError ) {
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
//    class func defaultErrorHandler(error: NSError ) {
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