
import Foundation

public typealias StorableDictionary = [String: Any]

public protocol Storable {

    static var typeName: String { get }

    var id: String? { get }

    func toDictionary() -> StorableDictionary

    init(dictionary: StorableDictionary)
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

extension String {

    public static func randomIdentifier(ofLength length: Int) -> String {

        let letters : String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.count)

        var randomString = ""

        for _ in 0 ..< length {

            let rand = arc4random_uniform(len)
            let nextChar = letters[letters.index(letters.startIndex, offsetBy: Int(rand))]
            randomString += "\(nextChar)"
        }

        return randomString
    }
}
