//
//  DataStore.swift
//  themixxapp
//
//  Created by Andre Barrett on 15/02/2016.
//  Copyright © 2016 MixxLabs. All rights reserved.
//

import Foundation

protocol Storable {
    
    static var typeName: String { get }
    
    var id: String? { get }
    
    func toDictionary() -> [String: AnyObject]
    
    init(dictionary: [String: AnyObject])
}

protocol DataStore {
    
    func fetchEntity<T: Storable>(type: T.Type, id: String) -> Storable?
    
    func fetchAllEntities<T: Storable>(type: T.Type, predicateOptional: NSPredicate?) -> [Storable]
    
    func storeEntity<T: Storable>(type: T.Type, entity: Storable)
    
    func storeEntities<T: Storable>(type: T.Type, entities: [Storable])
    
}

class DataStoreImpl: DataStore {
    
    var storageDictionary: NSMutableDictionary
    
    init(storageDictionary: NSMutableDictionary) {
        
        self.storageDictionary = storageDictionary
    }
    
    func fetchEntity<T: Storable>(type: T.Type, id: String) -> Storable? {
        
        var item: Storable?
        
        let typeDictionary = dictionaryForType(type.typeName)
        
        
            if let object = typeDictionary[id] as? [String: AnyObject] {
            
                item = T(dictionary: object)
            }
        
        
        return item
    }
    
    func fetchAllEntities<T: Storable>(type: T.Type, predicateOptional: NSPredicate?) -> [Storable] {
        
        var items = [Storable]()
        
        let typeDictionary = dictionaryForType(T.typeName)
        
            let filteredItems = typeDictionary.filter({ (id: String, value: AnyObject) -> Bool in

                var includeObject = true
                
                if let predicate = predicateOptional {
                    includeObject = predicate.evaluateWithObject(value)
                }
                
                return includeObject
            })
            
            filteredItems.forEach({ (id: String, value: AnyObject) -> () in
                
                let objectDictionary = value as! [String: AnyObject]
                
                let item = T(dictionary: objectDictionary)
                
                items.append(item)
            })
        
        
        return items
    }
    
    func storeEntity<T: Storable>(type: T.Type, entity: Storable) {
        
        var typeDictionary = dictionaryForType(T.typeName)

        if let id = entity.id {
         
            let itemDictionary = entity.toDictionary()
            
            typeDictionary[id] = itemDictionary
            
            self.storageDictionary.setValue(typeDictionary, forKey: type.typeName)
        }
    }
    
    func storeEntities<T: Storable>(type: T.Type, entities: [Storable]) {
        
        var typeDictionary = dictionaryForType(T.typeName)
        
        entities.forEach({ (storable) -> () in
            
            if let id = storable.id {
                typeDictionary[id] = storable.toDictionary()
            }
        })
        
        self.storageDictionary.setValue(typeDictionary, forKey: type.typeName)
    }
    
    func dictionaryForType(typeName: String) -> [String: AnyObject] {
        
        var typeDictionary: [String: AnyObject]! = self.storageDictionary.valueForKey(typeName) as? [String: AnyObject]
        
        if typeDictionary == nil {
            typeDictionary = [String: AnyObject]()
        }
        
        return typeDictionary
    }
}