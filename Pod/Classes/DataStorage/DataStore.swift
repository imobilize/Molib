
import Foundation

public typealias StorableDictionary = [String: AnyObject]

let kStorageDictionaryKey = "StorageDictionary"

public protocol Storable {
    
    static var typeName: String { get }
    
    var id: String? { get }
    
    func toDictionary() -> [String: AnyObject]
    
    init(dictionary: StorableDictionary)
}

public protocol DataStore {
    
    func fetchEntity<T: Storable>(type: T.Type, id: String) -> Storable?
    
    func fetchAllEntities<T: Storable>(type: T.Type) -> [Storable]
    
    func fetchEntities<T: Storable>(type: T.Type, predicateOptional: NSPredicate?) -> [Storable]
    
    func storeEntity<T: Storable>(type: T.Type, entity: Storable)
    
    func storeEntities<T: Storable>(type: T.Type, entities: [Storable])
    
    func removeEntity<T: Storable>(type: T.Type, entity: Storable)
    
    func removeEntities<T: Storable>(type: T.Type, entities: [Storable])
    
    func synchronize()

    func removeAllObjects()
}

public class DataStoreImpl: DataStore {
    
    var storageDictionary: NSMutableDictionary
    
    var userDefaults: UserDefaults
    
    public init(userDefaults: UserDefaults) {
        
        self.userDefaults = userDefaults
        
        if let dictionary = self.userDefaults.dictionaryForKey(kStorageDictionaryKey) {
            
            storageDictionary = NSMutableDictionary(dictionary: dictionary)
            
        } else {
            
            storageDictionary = NSMutableDictionary()
            
        }
        
    }
    
    public func synchronize() {
        
        var dict = [String: AnyObject]()
        
        for (key, value) in self.storageDictionary {
            dict[key as! String] = value
        }
        
        self.userDefaults.setDictionary(dict, forKey: kStorageDictionaryKey)
        
        self.userDefaults.synchronize()
    }
    
    
    public func fetchEntity<T: Storable>(type: T.Type, id: String) -> Storable? {
        
        var item: Storable?
        
        let typeDictionary = dictionaryForType(type.typeName)
        
        
        if let object = typeDictionary[id] as? StorableDictionary {
            
            item = T(dictionary: object)
        }
        
        
        return item
    }
    
    public func fetchAllEntities<T: Storable>(type: T.Type) -> [Storable] {
        
        return fetchEntities(type, predicateOptional: nil)
    }
    
    public func fetchEntities<T: Storable>(type: T.Type, predicateOptional: NSPredicate?) -> [Storable] {
        
        return fetchAllEntities(type, predicateOptional: predicateOptional)
    }
    
    
    public func storeEntity<T: Storable>(type: T.Type, entity: Storable) {
        
        var typeDictionary = dictionaryForType(T.typeName)
        
        if let id = entity.id {
            
            let itemDictionary = entity.toDictionary()
            
            typeDictionary[id] = itemDictionary
            
            self.storageDictionary.setValue(typeDictionary, forKey: type.typeName)
        }
    }
    
    public func storeEntities<T: Storable>(type: T.Type, entities: [Storable]) {
        
        var typeDictionary = dictionaryForType(T.typeName)
        
        entities.forEach({ (storable) -> () in
            
            if let id = storable.id {
                typeDictionary[id] = storable.toDictionary()
            }
        })
        
        self.storageDictionary.setValue(typeDictionary, forKey: type.typeName)
    }
    
    public func removeEntity<T: Storable>(type: T.Type, entity: Storable) {
        
        var typeDictionary = dictionaryForType(T.typeName)
        
        if let id = entity.id {
            
//            typeDictionary[id] = nil
            
            self.storageDictionary.setValue(nil, forKey: type.typeName)
        }
        
        
    }
    
    public func removeEntities<T: Storable>(type: T.Type, entities: [Storable]) {
    
    }
    
    public func removeAllObjects() {
        
        self.storageDictionary.removeAllObjects()
        
    }
    
    private func fetchAllEntities<T: Storable>(type: T.Type, predicateOptional: NSPredicate? = nil) -> [Storable] {
        
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
    
    func dictionaryForType(typeName: String) -> [String: AnyObject] {
        
        var typeDictionary: [String: AnyObject]! = self.storageDictionary.valueForKey(typeName) as? [String: AnyObject]
        
        if typeDictionary == nil {
            typeDictionary = [String: AnyObject]()
        }
        
        return typeDictionary
    }
}