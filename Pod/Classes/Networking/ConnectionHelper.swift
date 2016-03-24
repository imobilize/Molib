import Foundation

class ConnectionHelper: MOConnectionHelper {
    
    var dictionary: [String: String]
    
    init() {
        
        dictionary = Dictionary()
    }
    
    func relativeURLStringForKey(key:String) -> String {
        
        return dictionary[key]!
    }
    
    func absoluteURLStringForKey(key: String) -> String {
        
        return dictionary[key]!
    }
    
    func absoluteURLForKey(key: String) -> NSURL {
        
        let urlString = dictionary[key]!
        
        let url = NSURL(string: urlString)
        
        return url!
    }
}