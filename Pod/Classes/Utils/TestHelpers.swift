
import Foundation

class TestHelpers {
    
    class func jsonFromFile(file: String) -> AnyObject {
        
        var returnJSON: AnyObject?
        
        let data = dataFromFile(file)
        
        if data != nil {
            
            do {
                returnJSON = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableLeaves.union(NSJSONReadingOptions.MutableContainers))
                
            } catch let error as NSError {
                
                print("Couldn't parse JSON loaded from test file: %@", error)

                returnJSON = Dictionary<String, String>()

            }
            
        } else {
                        
            returnJSON = Dictionary<String, String>()
        }
 
        return returnJSON!
    }
    
    class func dataFromFile(file: String) -> NSData? {
        
        var returnData: NSData?
        
        let bundle = NSBundle(forClass: self)
        
        let filePath = bundle.pathForResource(file, ofType: "json")
        
        do {
            
            if (filePath == nil) {
                throw NSError(domain: "TestHelpers", code: 101, userInfo: nil)
            }
            
            let data : NSData? = try NSData(contentsOfFile:filePath!, options: NSDataReadingOptions.DataReadingUncached)
            
            returnData = data
            
        } catch let error as NSError {
            
            print("Couldn't load Data from test file: %@", error)
        }
        
        return returnData
    }
}