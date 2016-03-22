//
//  NSManagedObjectContext+Helpers.swift
//  OnIt
//
//  Created by Andre Barrett on 29/01/2016.
//  Copyright © 2016 imobilize. All rights reserved.
//

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
