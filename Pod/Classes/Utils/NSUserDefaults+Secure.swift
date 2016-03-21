
import Foundation


let kDefaultsKey = "Defaults"
let kSecureDefaultsKey = "SecureDefaults"


var defaultsDictionary: NSMutableDictionary! = nil

var secureItemsDictionary: NSMutableDictionary! = nil


struct UserDefaultsImpl: UserDefaults {

    
    init() {
        
        if(defaultsDictionary == nil) {
            
            let dictionary = NSUserDefaults.standardUserDefaults().dictionaryForKey(kDefaultsKey)
            
            if dictionary != nil {
            
                defaultsDictionary = NSMutableDictionary(dictionary: dictionary!)
            } else {
                
                defaultsDictionary = NSMutableDictionary()
            }
            
            let secureDictionary = defaultsDictionary.objectForKey(kSecureDefaultsKey) as? NSDictionary
            
            if secureDictionary != nil {
            
                let decryptedDictionary = decryptDictionary(secureDictionary!)
                
                secureItemsDictionary = NSMutableDictionary(dictionary: decryptedDictionary)
            } else {
                
                secureItemsDictionary = NSMutableDictionary()
            }
        }
    }
    
    func stringForKey(key: String) -> String? {
        
        return defaultsDictionary.objectForKey(key) as? String
    }
    
    func secureStringForKey(key: String) -> String? {
        
        return secureItemsDictionary.objectForKey(key) as? String
    }
    
    func dictionaryForKey(key: String) -> Dictionary<String, AnyObject>? {
        
        return defaultsDictionary.objectForKey(key) as? Dictionary
    }
    
    func dataForKey(key: String) -> NSData? {
        
        return defaultsDictionary.objectForKey(key) as? NSData
    }
    
    func boolForKey(key: String) -> Bool? {
        
        let number = defaultsDictionary.objectForKey(key) as? NSNumber
        
        return number?.boolValue
    }
    
    
    //MARK: Setting methods

    func setString(value: String?, forKey key: String) {
        
        setItem(value, forKey: key)
    }
    
    func setSecureString(value: String?, forKey key: String) {
    
        if(secureItemsDictionary == nil) {
    
            secureItemsDictionary = NSMutableDictionary()
        }
    
        if (value == nil) {
    
            secureItemsDictionary.removeObjectForKey(key)
            
        } else {
    
            secureItemsDictionary[key] = value
        }
    }
    
    func setDictionary(value: Dictionary<String, AnyObject>, forKey key: String) {
    
        setItem(value, forKey:key)
    }
    
    func setData(value: NSData?, forKey key: String) {
    
        setItem(value, forKey:key)
    }
    
    func setBool(value: Bool, forKey key: String) {
    
        let number = NSNumber(bool: value)
    
        setItem(number, forKey:key)
    }
    
    func synchronize() -> Bool {
    
        if (secureItemsDictionary != nil) {
    
            let encryptedDictionary = encryptDictionary(secureItemsDictionary)
    
            defaultsDictionary[kSecureDefaultsKey] = encryptedDictionary
        }
    
        let defaults = NSUserDefaults.standardUserDefaults()
    
        defaults.setObject(defaultsDictionary, forKey: kDefaultsKey)
    
        return defaults.synchronize()
    }

    
    //MARK: - Helpers
    
    private func setItem(value: AnyObject?, forKey key: String) {
    
        if (value == nil) {
    
            defaultsDictionary.removeObjectForKey(key)
            
        } else {
    
            defaultsDictionary[key] = value
        }
        
        synchronize()
    }
    
    private func decryptDictionary(dictionary: NSDictionary) -> NSDictionary {
    
        let decryptedDictionary = NSMutableDictionary()
        
        dictionary.enumerateKeysAndObjectsUsingBlock() {
            
            (dictionaryKey, obj, stop) in
    
            let key = dictionaryKey as! String
            
            if let secureData = obj as? NSData {
                
                let decryptedData = secureData.AES256DecryptWithKey(key)
                
                if let data = decryptedData {

                    let value = NSString(data: data, encoding: NSUTF8StringEncoding)
    
                    decryptedDictionary.setValue(value, forKey: key)
                }
            }
    
        }
    
        return decryptedDictionary
    }

    private func encryptDictionary(dictionary:NSDictionary) -> NSDictionary {
    
        let encryptedDictionary = NSMutableDictionary()
    
        dictionary.enumerateKeysAndObjectsUsingBlock() {
            
            (dictionaryKey, obj, stop) in
    
            let key = dictionaryKey as! String

            let item = obj as! String
            
            let data = item.dataUsingEncoding(NSUTF8StringEncoding)
            
            if data != nil {

                let encryptedData = data!.AES256EncryptWithKey(key)
    
                if encryptedData != nil {
            
                    encryptedDictionary.setValue(encryptedData, forKey: key)
                }
            }
    
        }
    
        return encryptedDictionary;
    }
}
