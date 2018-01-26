import Foundation

public class ObjectDataCache<Key: Hashable & CustomStringConvertible, Object: AnyObject>: DataCache {

    public typealias KeyType = String
    public typealias ObjectType = Object

    private var cacheTimeout: TimeInterval = 8000
    private let dataCache: NSCache<AnyObject, Object>
    private var lastCacheUpdate: Date?

    public init() {
        self.dataCache = NSCache<AnyObject, Object>()
    }

    public func object(forKey key: KeyType) -> ObjectType? {

        let objectKey = NSString(string: "\(key)")

        if let lastUpdate = lastCacheUpdate {

            if lastUpdate.addingTimeInterval(cacheTimeout) < Date() {
                dataCache.removeAllObjects()
            }
        }

        return dataCache.object(forKey: objectKey)
    }

    public func setObject(_ obj: ObjectType, forKey key: KeyType) {

        let objectKey = NSString(string: "\(key)")
        dataCache.setObject(obj, forKey: objectKey)
        lastCacheUpdate = Date()
    }

    public func removeObject(forKey key: KeyType) {

        let objectKey = NSString(string: "\(key)")
        dataCache.removeObject(forKey: objectKey)
        lastCacheUpdate = Date()
    }

    public func removeAllObjects() {

        dataCache.removeAllObjects()
        lastCacheUpdate = Date()
    }

    public func lastUpdateDate() -> Date? {
        return lastCacheUpdate
    }

    public func setCacheExpiryTimeout(timeoutInSecs: TimeInterval) {
        cacheTimeout = timeoutInSecs
    }

    public func hasExpired() -> Bool {

        var expired = true

        if let lastUpdate = lastCacheUpdate, lastUpdate.addingTimeInterval(cacheTimeout) > Date() {

            expired = false
        }

        return expired
    }

    public func expireCache() {
        lastCacheUpdate = nil
    }
}
