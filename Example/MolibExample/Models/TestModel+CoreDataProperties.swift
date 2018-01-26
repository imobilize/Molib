//
//  TestModel+CoreDataProperties.swift
//  
//
//  Created by Andre Barrett on 14/09/2015.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension TestModel {

    @NSManaged var name: String?
    @NSManaged var modelDescription: String?
    @NSManaged var id: String?

}
