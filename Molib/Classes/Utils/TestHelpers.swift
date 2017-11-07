
import Foundation

class TestHelpers {
    
    class func jsonFromFile(file: String) -> AnyObject {
        
        var returnJSON: AnyObject?
        
        let data = dataFromFile(file: file)
        
        if data != nil {
            
            do {
                returnJSON = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves.union(JSONSerialization.ReadingOptions.mutableContainers)) as AnyObject
                
            } catch let error {
                
                print("Couldn't parse JSON loaded from test file: %@", error)

                returnJSON = Dictionary<String, String>() as AnyObject

            }
            
        } else {
                        
            returnJSON = Dictionary<String, String>() as AnyObject
        }
 
        return returnJSON!
    }
    
    class func dataFromFile(file: String) -> Data? {
        
        var returnData: Data?
        
        let bundle = Bundle(for: self)
        
        let filePath = bundle.path(forResource: file, ofType: "json")
        
        do {

            if let path = filePath, let url = URL(string: path) {

                let data : Data? = try Data(contentsOf: url, options: .uncached)

                returnData = data
            } else {
                throw NSError(domain: "TestHelpers", code: 101, userInfo: nil)
            }
        } catch let error {
            
            print("Couldn't load Data from test file: %@", error)
        }
        
        return returnData
    }
}
