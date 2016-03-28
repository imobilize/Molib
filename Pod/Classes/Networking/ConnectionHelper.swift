import Foundation

public class ConnectionHelper: MOConnectionHelper {
    
    var dictionary: [String: String]
    
    public init() {
        
        dictionary = Dictionary()
    }
    
    public func relativeURLStringForKey(key:String) -> String {
        
        return dictionary[key]!
    }
    
    public func absoluteURLStringForKey(key: String) -> String {
        
        return dictionary[key]!
    }
    
    public func absoluteURLForKey(key: String) -> NSURL {
        
        let urlString = dictionary[key]!
        
        let url = NSURL(string: urlString)
        
        return url!
    }
}

extension String {
    
    public func URLReplacingPathParamaters(parameters: Dictionary<String, String>) -> String {
        
        var path = self
        
        for (key, value) in parameters {
            
            let str = "{\(key)}"
            
            path = path.stringByReplacingOccurrencesOfString(str, withString: value)
            
            
        }
        
        if let finalPath = path.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) {
            
            path = finalPath
        }
        
        return path
    }
}


