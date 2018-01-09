import Foundation

public protocol DataCache where KeyType : Hashable, ObjectType : AnyObject {

    associatedtype KeyType
    associatedtype ObjectType

    func object(forKey key: KeyType) -> ObjectType?

    func setObject(_ obj: ObjectType, forKey key: KeyType)

    func removeObject(forKey key: KeyType)

    func removeAllObjects()

    func lastUpdateDate() -> Date?

    func setCacheExpiryTimeout(timeoutInSecs: TimeInterval)

    func hasExpired() -> Bool

    func expireCache()
}
