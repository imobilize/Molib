
import Foundation
import CoreData

extension NSManagedObject {

    open override func value(forUndefinedKey key: String) -> Any? {

        print("Not able to set undefined key: %@", key)
        
        return nil
    }

    open override func setValue(_ value: Any?, forUndefinedKey key: String) {

        print("Couldn't set value for key: %@", key)
    }
}


public extension NSManagedObject {
    
    public func configureWithDictionary(dictionary: [NSObject: AnyObject]) {
        
        safeSetValuesForKeysWithDictionary(keyedValues: dictionary)
    }

    func safeSetValuesForKeysWithDictionary(keyedValues: Dictionary<NSObject, AnyObject>) {
        
        let dateFormatter: DateFormatter = DateFormatter()
    //The Z at the end of your string represents Zulu which is UTC
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
    
        safeSetValuesForKeysWithDictionary(keyedValues: keyedValues, dateFormatter:dateFormatter)
    }
    
    func safeSetValuesForKeysWithDictionary(keyedValues: Dictionary<NSObject, AnyObject>, dateFormatter:DateFormatter) {
        
        let attributes = self.entity.attributesByName
        
        for (key, _) in attributes {
            
            let valueOptional: AnyObject? = keyedValues[key]
            
            if var value: AnyObject = valueOptional {
    
            let attributeDescriptionOptional = attributes[key]
            
            if let attribute = attributeDescriptionOptional {
                
                let attributeType =  attribute.attributeType

                switch attributeType {
                    
                case .StringAttributeType:
                    
                    if value.isKindOfClass(NSNumber.self) {
                        
                        value = value.stringValue
                        
                    } else if value.isKindOfClass(NSNull.self) {
                        
                        value = ""
                    } else if value.isKindOfClass(NSString.self) {
                        
                        let range = value.rangeOfString("^\\s*")
                        
                        if range.location != NSNotFound {
                        
                            let result = value.stringByReplacingCharactersInRange(range, withString: "")
                            value = result
                        }
                    }
                    
                case .Integer16AttributeType, .Integer32AttributeType, .Integer64AttributeType, .BooleanAttributeType:
                    
                    if value.isKindOfClass(NSString.self) {
                        
                        value = NSNumber(long: value.integerValue)
                    }
                case .FloatAttributeType:
                    
                    if value.isKindOfClass(NSString.self) {
                        
                        value = NSNumber(double: value.doubleValue)
                    }
                    
                case .DateAttributeType:
                    
                    if value.isKindOfClass(NSString.self) {
                        
                        value = dateFormatter.dateFromString(value as! String)!
                        
                    } else if value.isKindOfClass(NSNumber.self) {
                        
                        value = NSDate(timeIntervalSince1970: value.doubleValue / 1000)
                    }
                    
                default:
                    
                    break
                }
                
                if value.isKindOfClass(NSNull.self) == false {
                
                    self.setValue(value, forKey:key )
                }
                }
                
            }
        }
    }
    
    func dictionary() -> [String: AnyObject] {
    
        var dictionary = [String: AnyObject]()
    
        let attributes = self.entity.attributesByName
        
        for (key, _) in attributes {

            if let value: AnyObject = self.valueForKey(key ) {
            
                dictionary[key ] = value
            }
        }
    
        return dictionary
    }

}
