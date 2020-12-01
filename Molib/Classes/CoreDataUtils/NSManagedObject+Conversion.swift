
import Foundation
import CoreData

extension NSManagedObject {

    open override func value(forUndefinedKey key: String) -> Any? {

       debugPrint("Not able to set undefined key: %@", key)
        
        return nil
    }

    open override func setValue(_ value: Any?, forUndefinedKey key: String) {

       debugPrint("Couldn't set value for key: %@", key)
    }
}


public extension NSManagedObject {
    
    public func configureWithDictionary(dictionary: [String: Any]) {
        
        safeSetValuesForKeysWithDictionary(keyedValues: dictionary)
    }

    func safeSetValuesForKeysWithDictionary(keyedValues: Dictionary<String, Any>) {
        
        let dateFormatter: DateFormatter = DateFormatter()
        //The Z at the end of your string represents Zulu which is UTC
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

        safeSetValuesForKeysWithDictionary(keyedValues: keyedValues, dateFormatter:dateFormatter)
    }
    
    func safeSetValuesForKeysWithDictionary(keyedValues: Dictionary<String, Any>, dateFormatter:DateFormatter) {
        
        let attributes: [String: NSAttributeDescription] = self.entity.attributesByName
        
        for (key, _) in attributes {
            
            let valueOptional = keyedValues[key] as? AnyObject
            
            if var value: AnyObject = valueOptional {

                if let attribute = attributes[key] {

                    let attributeType =  attribute.attributeType

                    switch attributeType {

                    case .stringAttributeType:

                        if let number = value as? NSNumber {

                            value = number.stringValue as AnyObject

                        } else if let _ = value as? NSNull {

                            value = "" as AnyObject
                        } else if let string = value as? NSString {

                            let range = string.range(of: "^\\s*")

                            if range.location != NSNotFound {

                                let result = string.replacingCharacters(in: range, with: "")
                                value = result as AnyObject
                            }
                        }

                    case .integer16AttributeType, .integer32AttributeType, .integer64AttributeType, .booleanAttributeType:

                        if let number = value as? NSString {

                            value = NSNumber(value: number.integerValue)
                        }
                    case .floatAttributeType:

                        if let number = value as? NSString {

                            value = NSNumber(value: number.doubleValue)
                        }

                    case .dateAttributeType:

                        if let number = value as? String {

                            if let formattedDate = dateFormatter.date(from: number) {
                                value = formattedDate as AnyObject
                            } else {
                                value = "" as AnyObject
                            }
                        } else if let number = value as? NSNumber {

                            value = NSDate(timeIntervalSince1970: number.doubleValue / 1000)
                        }

                    default:

                        break
                    }

                    if value.isKind(of: NSNull.self) == false {

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

            if let value: AnyObject = self.value(forKey: key) as AnyObject? {

                dictionary[key ] = value
            }
        }

        return dictionary
    }

}
