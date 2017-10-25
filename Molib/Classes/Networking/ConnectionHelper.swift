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
    
    public func absoluteURLForKey(key: String) -> URL {
        
        let urlString = dictionary[key]!
        
        let url = URL(string: urlString)
        
        return url!
    }
}

extension String {
    
    public func URLReplacingPathParamaters(parameters: Dictionary<String, String>) -> String {
        
        var path = self
        
        for (key, value) in parameters {
            
            let str = "{\(key)}"
            
            path = path.replacingOccurrences(of: str, with: value)
        }
        
        if let finalPath = path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            
            path = finalPath
        }
        
        return path
    }
}


