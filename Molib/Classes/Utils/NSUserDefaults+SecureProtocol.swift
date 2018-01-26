
import Foundation


public protocol UserConfig {
    
    func stringForKey(key: String) -> String?
    
    func secureStringForKey(key: String) -> String?
    
    func dictionaryForKey(key: String) -> Dictionary<String, AnyObject>?
    
    func dataForKey(key: String) -> NSData?
    
    func boolForKey(key: String) -> Bool?
    
    func integerForKey(key: String) -> Int?
    
    //MARK: Setting methods
    
    func setString(value: String?, forKey key: String)
    
    func setSecureString(value: String?, forKey key: String)
    
    func setDictionary(value: Dictionary<String, AnyObject>, forKey key: String)
    
    func setData(value: NSData?, forKey key: String)
    
    func setBool(value: Bool, forKey key: String)
    
    func setInteger(value: Int, forKey key: String)
    
    func synchronize() -> Bool
}
