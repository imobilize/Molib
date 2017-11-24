
import Foundation

public typealias StorableDictionary = [String: AnyObject]

public protocol Storable {
    
    static var typeName: String { get }
    
    var id: String? { get }
    
    func toDictionary() -> StorableDictionary
    
    init(dictionary: StorableDictionary)
}

public protocol Downloadable {
    
    func uniqueIdentifier() -> String

    func downloadName() -> String
    
    func url() -> URL
    
    func localURL() -> URL
}


public protocol DataStore {
    
    func fetchEntity<T: Storable>(type: T.Type, id: String) -> T?
    
    func fetchAllEntities<T: Storable>(type: T.Type) -> [T]
    
    func fetchEntities<T: Storable>(type: T.Type, predicateOptional: NSPredicate?) -> [T]
    
    func storeEntity<T: Storable>(type: T.Type, entity: T)
    
    func storeEntities<T: Storable>(type: T.Type, entities: [T])
    
    func removeEntity<T: Storable>(type: T.Type, entity: T)
    
    func removeEntities<T: Storable>(type: T.Type, entities: [T])
    
    func synchronize()

    func removeAllObjects()
}

public class InMemoryDataStore: DataStore {

    private var storageDictionary: NSMutableDictionary

    public init() {
        storageDictionary = NSMutableDictionary()
    }

    public init(dictionary: NSMutableDictionary) {
        storageDictionary = dictionary
    }

    public func synchronize() {}

    public func fetchEntity<T: Storable>(type: T.Type, id: String) -> T? {

        var item: T?

        let typeDictionary = dictionaryForType(typeName: type.typeName)


        if let object = typeDictionary[id] as? StorableDictionary {

            item = T(dictionary: object)
        }


        return item
    }

    public func fetchAllEntities<T: Storable>(type: T.Type) -> [T] {

        return fetchEntities(type: type, predicateOptional: nil)
    }

    public func fetchEntities<T: Storable>(type: T.Type, predicateOptional: NSPredicate?) -> [T] {

        return fetchAllEntities(type: type, predicateOptional: predicateOptional)
    }


    public func storeEntity<T>(type: T.Type, entity: T) where T : Storable {

        var typeDictionary = dictionaryForType(typeName: T.typeName)

        if let id = entity.id {

            let itemDictionary = entity.toDictionary()

            typeDictionary[id] = itemDictionary as AnyObject

            self.storageDictionary.setValue(typeDictionary, forKey: type.typeName)
        }
    }

    public func storeEntities<T: Storable>(type: T.Type, entities: [T]) {

        var typeDictionary = dictionaryForType(typeName: T.typeName)

        entities.forEach({ (storable) -> () in

            if let id = storable.id {
                typeDictionary[id] = storable.toDictionary() as AnyObject
            }
        })

        self.storageDictionary.setValue(typeDictionary, forKey: type.typeName)
    }
    //Mark: TODO FIX THIS
    public func removeEntity<T>(type: T.Type, entity: T) where T : Storable {

        var typeDictionary = dictionaryForType(typeName: T.typeName)

        if (entity.id) != nil {

            self.storageDictionary.setValue(nil, forKey: type.typeName)
        }
    }

    public func removeEntities<T>(type: T.Type, entities: [T]) where T : Storable {

    }

    public func removeAllObjects() {

        self.storageDictionary.removeAllObjects()

    }

    private func fetchAllEntities<T: Storable>(type: T.Type, predicateOptional: NSPredicate? = nil) -> [T] {

        var items = [T]()

        let typeDictionary = dictionaryForType(typeName: T.typeName)

        let filteredItems = typeDictionary.filter({ (id: String, value: AnyObject) -> Bool in

            var includeObject = true

            if let predicate = predicateOptional {
                includeObject = predicate.evaluate(with: value)
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

    private func dictionaryForType(typeName: String) -> [String: AnyObject] {

        var typeDictionary: [String: AnyObject]! = self.storageDictionary.value(forKey: typeName) as? [String: AnyObject]

        if typeDictionary == nil {
            typeDictionary = [String: AnyObject]()
        }

        return typeDictionary
    }

    fileprivate func underlyingDictionary() -> NSMutableDictionary {
        return self.storageDictionary
    }
}

public class UserConfigDataStore: InMemoryDataStore {

    private let kStorageDictionaryKey = "StorageDictionary"

    private var userDefaults: UserConfig


    public init(userDefaults: UserConfig) {

        self.userDefaults = userDefaults

        if let dictionary = self.userDefaults.dictionaryForKey(key: kStorageDictionaryKey) {

            let storageDictionary = NSMutableDictionary(dictionary: dictionary)
            super.init(dictionary: storageDictionary)
        } else {
            super.init()
        }
    }

    public override func synchronize() {

        var dict = [String: AnyObject]()

        for (key, value) in self.underlyingDictionary() {
            dict[key as! String] = value as AnyObject
        }

        self.userDefaults.setDictionary(value: dict, forKey: kStorageDictionaryKey)

        _ = self.userDefaults.synchronize()
    }
}
