
import Foundation


let kDefaultsKey = "Defaults"
let kSecureDefaultsKey = "SecureDefaults"


var defaultsDictionary: NSMutableDictionary! = nil

var secureItemsDictionary: NSMutableDictionary! = nil


public struct UserDefaultsImpl: UserDefaults {

    
    public init() {
        
        if(defaultsDictionary == nil) {
            
            let dictionary = Foundation.UserDefaults.standard.dictionary(forKey: kDefaultsKey)
            
            if dictionary != nil {
            
                defaultsDictionary = NSMutableDictionary(dictionary: dictionary!)
            } else {
                
                defaultsDictionary = NSMutableDictionary()
            }
            
            let secureDictionary = defaultsDictionary.object(forKey: kSecureDefaultsKey) as? NSDictionary
            
            if secureDictionary != nil {
            
                let decryptedDictionary = decryptDictionary(dictionary: secureDictionary!)
                
                secureItemsDictionary = NSMutableDictionary(dictionary: decryptedDictionary)
            } else {
                
                secureItemsDictionary = NSMutableDictionary()
            }
        }
    }
    
    public func stringForKey(key: String) -> String? {
        
        return defaultsDictionary.object(forKey: key) as? String
    }
    
    public func secureStringForKey(key: String) -> String? {
        
        return secureItemsDictionary.object(forKey: key) as? String
    }
    
    public func dictionaryForKey(key: String) -> Dictionary<String, AnyObject>? {
        
        return defaultsDictionary.object(forKey: key) as? Dictionary
    }
    
    public func dataForKey(key: String) -> NSData? {
        
        return defaultsDictionary.object(forKey: key) as? NSData
    }
    
    public func boolForKey(key: String) -> Bool? {
        
        let number = defaultsDictionary.object(forKey: key) as? NSNumber
        
        return number?.boolValue
    }
    
    public func integerForKey(key: String) -> Int? {
        
        return defaultsDictionary.object(forKey: key) as? Int
        
    }
    
    //MARK: Setting methods

    public func setString(value: String?, forKey key: String) {
        
        setItem(value: value as AnyObject, forKey: key)
    }
    
    public func setSecureString(value: String?, forKey key: String) {
    
        if(secureItemsDictionary == nil) {
    
            secureItemsDictionary = NSMutableDictionary()
        }
    
        if (value == nil) {
    
            secureItemsDictionary.removeObject(forKey: key)
            
        } else {
    
            secureItemsDictionary[key] = value
        }
    }
    
    public func setDictionary(value: Dictionary<String, AnyObject>, forKey key: String) {
    
        setItem(value: value as AnyObject, forKey:key)
    }
    
    public func setData(value: NSData?, forKey key: String) {
    
        setItem(value: value, forKey:key)
    }
    
    public func setBool(value: Bool, forKey key: String) {
    
        let number = NSNumber(value: value)
    
        setItem(value: number, forKey:key)
    }
    
    public func setInteger(value: Int, forKey key: String) {
        
        setItem(value: value as AnyObject, forKey: key)
    }
    
    public func synchronize() -> Bool {
    
        if (secureItemsDictionary != nil) {
    
            let encryptedDictionary = encryptDictionary(dictionary: secureItemsDictionary)
    
            defaultsDictionary[kSecureDefaultsKey] = encryptedDictionary
        }
    
        let defaults = Foundation.UserDefaults.standard
    
        defaults.set(defaultsDictionary, forKey: kDefaultsKey)
    
        return defaults.synchronize()
    }

    
    //MARK: - Helpers
    
    private func setItem(value: AnyObject?, forKey key: String) {
    
        if (value == nil) {
    
            defaultsDictionary.removeObject(forKey: key)
            
        } else {
    
            defaultsDictionary[key] = value
        }
        
        _ = synchronize()
    }
    
    private func decryptDictionary(dictionary: NSDictionary) -> NSDictionary {
    
        let decryptedDictionary = NSMutableDictionary()
        
        dictionary.enumerateKeysAndObjects() {
            
            (dictionaryKey, obj, stop) in
    
            let key = dictionaryKey as! String
            
            if let secureData = obj as? Data {
                
                let decryptedData = secureData.AESDecryptWithKey(key: key)
                
                if let data = decryptedData {

                    let value = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
    
                    decryptedDictionary.setValue(value, forKey: key)
                }
            }
    
        }
    
        return decryptedDictionary
    }

    private func encryptDictionary(dictionary:NSDictionary) -> NSDictionary {
    
        let encryptedDictionary = NSMutableDictionary()
    
        dictionary.enumerateKeysAndObjects() {
            
            (dictionaryKey, obj, stop) in
    
            let key = dictionaryKey as! String

            let item = obj as! String
            
            let data = item.data(using: String.Encoding.utf8)
            
            if data != nil {

                let encryptedData = data!.AESEncryptWithKey(key: key)
    
                if encryptedData != nil {
            
                    encryptedDictionary.setValue(encryptedData, forKey: key)
                }
            }
    
        }
    
        return encryptedDictionary;
    }
}
