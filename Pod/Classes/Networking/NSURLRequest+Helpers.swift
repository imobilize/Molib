
import Foundation
import Alamofire


extension NSURLRequest {
    
    public convenience init?(urlString: String) {
        
        let url = NSURL(string: urlString)
        
        if url != nil {
            
            self.init(URL: url!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 15)
        } else {
            return nil
        }
    }
    
    public class func POSTRequestJSON(urlString: String, bodyParameters: [String: AnyObject]) -> NSURLRequest? {
        
        if let url = NSURL(string: urlString) {
            
            let request = NSMutableURLRequest(URL: url)
            
            request.HTTPMethod = RequestMethod.POST.rawValue
            
            let encoder: URLRequestEncoding = .JSON
            
            let tuple = encoder.encode(request, parameters: bodyParameters)
            
            return tuple.0
        } else {
            
            return nil
        }
    }
    
    public class func PUTRequestJSON(urlString: String, bodyParameters: [String: AnyObject]) -> NSURLRequest? {
        
        if let url = NSURL(string: urlString) {
            
            let request = NSMutableURLRequest(URL: url)
            
            request.HTTPMethod = RequestMethod.PUT.rawValue
            
            let encoder: URLRequestEncoding = .JSON
            
            let tuple = encoder.encode(request, parameters: bodyParameters)
            
            return tuple.0
        } else {
            
            return nil
        }
    }
    
    public class func PUTRequest(urlString: String, bodyData: NSData) -> NSURLRequest? {
        
        if let url = NSURL(string: urlString) {
            
            let request = NSMutableURLRequest(URL: url)
            
            request.HTTPMethod = RequestMethod.PUT.rawValue
            
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            request.HTTPBody = bodyData
            
            return request
            
        } else {
            
            return nil
        }
    }
    
    public class func POSTRequest(urlString: String, bodyParameters: AnyObject) -> NSURLRequest? {
        
        if let url = NSURL(string: urlString) {
            
            let request = NSMutableURLRequest(URL: url)
            
            request.HTTPMethod = RequestMethod.POST.rawValue
            
            let encoder: URLRequestEncoding = .URL
            
            let tuple = encoder.encode(request, parameters: bodyParameters)
            
            return tuple.0
        } else {
            
            return nil
        }
    }
    
    public class func POSTRequest(urlString: String, bodyData: NSData? = nil) -> NSURLRequest? {
        
        if let url = NSURL(string: urlString) {
            
            let request = NSMutableURLRequest(URL: url)
            
            request.HTTPMethod = RequestMethod.POST.rawValue
            
            request.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
            
            request.HTTPBody = bodyData
            
            return request
            
        } else {
            
            return nil
        }
    }
    
    public class func GETRequest(urlString: String) -> NSURLRequest? {
        
        return NSURLRequest.init(urlString: urlString)
    }
    
    public class func GETRequest(urlString: String, parameters: [String: AnyObject]) -> NSURLRequest? {
        
        if let url = NSURL(string: urlString) {
            
            let request = NSMutableURLRequest(URL: url)
            
            request.HTTPMethod = RequestMethod.GET.rawValue
            
            let encoder: ParameterEncoding = .URLEncodedInURL
            
            let tuple = encoder.encode(request, parameters: parameters)
            
            return tuple.0
            
        } else {
            
            return nil
        }
    }
    
    public class func DELETERequest(urlString: String) -> NSURLRequest? {
        
        let request = NSMutableURLRequest.init(urlString: urlString)
        
        request?.HTTPMethod = "DELETE"
        
        return request
    }
    
}


public enum RequestMethod: String {
    case OPTIONS, GET, HEAD, POST, PUT, PATCH, DELETE, TRACE, CONNECT
}

public enum URLRequestEncoding {
    case URL
    case URLEncodedInURL
    case JSON
    case PropertyList(NSPropertyListFormat, NSPropertyListWriteOptions)
    case Custom((URLRequestConvertible, AnyObject?) -> (NSMutableURLRequest, NSError?))
    
    /**
     Creates a URL request by encoding parameters and applying them onto an existing request.
     
     - parameter URLRequest: The request to have parameters applied
     - parameter parameters: The parameters to apply
     
     - returns: A tuple containing the constructed request and the error that occurred during parameter encoding,
     if any.
     */
    public func encode(
        URLRequest: URLRequestConvertible,
        parameters: AnyObject?)
        -> (NSMutableURLRequest, NSError?)
    {
        var mutableURLRequest = URLRequest.URLRequest
        
        var encodingError: NSError? = nil
        
        guard let params = parameters as? [String: AnyObject] else {
            return (mutableURLRequest, nil)
        }
        
        switch self {
        case .URL, .URLEncodedInURL:
            
            guard let params = parameters as? [String: AnyObject] else {
                return (mutableURLRequest, nil)
            }
            
            encodeRequestWithTypeURL(mutableURLRequest, params: params)
            
        case .JSON:
            
            encodeRequestWithTypeJSON(mutableURLRequest, params: params)
            
        case .PropertyList(let format, let options):
            
            encodeRequestWithTypePropertyList(mutableURLRequest, params: params, types: (format, options))
            
        case .Custom(let closure):
            (mutableURLRequest, encodingError) = closure(mutableURLRequest, params)
        }
        
        return (mutableURLRequest, encodingError)
        
    }
    
    
    func encodeRequestWithTypeURL(mutableURLRequest: NSMutableURLRequest, params: [String: AnyObject]) -> (NSMutableURLRequest, NSError?)  {
        
        var encodingError: NSError? = nil
        
        func query(parameters: [String: AnyObject]) -> String {
            var components: [(String, String)] = []
            
            for key in parameters.keys.sort(<) {
                let value = parameters[key]!
                components += queryComponents(key, value)
            }
            
            return (components.map { "\($0)=\($1)" } as [String]).joinWithSeparator("&")
        }
        
        func encodesParametersInURL(method: RequestMethod) -> Bool {
            switch self {
            case .URLEncodedInURL:
                return true
            default:
                break
            }
            
            switch method {
            case .GET, .HEAD, .DELETE:
                return true
            default:
                return false
            }
        }
        
        if let method = RequestMethod(rawValue: mutableURLRequest.HTTPMethod) where encodesParametersInURL(method) {
            if let URLComponents = NSURLComponents(URL: mutableURLRequest.URL!, resolvingAgainstBaseURL: false) {
                let percentEncodedQuery = (URLComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + query(params )
                URLComponents.percentEncodedQuery = percentEncodedQuery
                mutableURLRequest.URL = URLComponents.URL
            }
        } else {
            if mutableURLRequest.valueForHTTPHeaderField("Content-Type") == nil {
                mutableURLRequest.setValue(
                    "application/x-www-form-urlencoded; charset=utf-8",
                    forHTTPHeaderField: "Content-Type"
                )
            }
            
            mutableURLRequest.HTTPBody = query(params ).dataUsingEncoding(
                NSUTF8StringEncoding,
                allowLossyConversion: false
            )
        }
        
        return (mutableURLRequest, encodingError)
    }
    
    func encodeRequestWithTypeJSON(mutableURLRequest: NSMutableURLRequest, params: AnyObject) -> (NSMutableURLRequest, NSError?)  {
        
        var encodingError: NSError? = nil
        
        do {
            let options = NSJSONWritingOptions()
            let data = try NSJSONSerialization.dataWithJSONObject(params, options: options)
            
            mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            mutableURLRequest.HTTPBody = data
        } catch {
            
            
            encodingError = error as NSError
        }
        
        return (mutableURLRequest, encodingError)
    }
    
    
    func encodeRequestWithTypePropertyList(mutableURLRequest: NSMutableURLRequest, params: AnyObject, types: (format: NSPropertyListFormat, options: NSPropertyListWriteOptions)) -> (NSMutableURLRequest, NSError?)  {
        
        var encodingError: NSError? = nil
        
        do {
            let data = try NSPropertyListSerialization.dataWithPropertyList(
                params,
                format: types.format,
                options: types.options
            )
            mutableURLRequest.setValue("application/x-plist", forHTTPHeaderField: "Content-Type")
            mutableURLRequest.HTTPBody = data
        } catch {
            encodingError = error as NSError
        }
        
        return (mutableURLRequest, encodingError)
    }
    
    
    /**
     Creates percent-escaped, URL encoded query string components from the given key-value pair using recursion.
     
     - parameter key:   The key of the query component.
     - parameter value: The value of the query component.
     
     - returns: The percent-escaped, URL encoded query string components.
     */
    public func queryComponents(key: String, _ value: AnyObject) -> [(String, String)] {
        
        var components: [(String, String)] = []
        
        if let dictionary = value as? [String: AnyObject] {
            for (nestedKey, value) in dictionary {
                components += queryComponents("\(key)[\(nestedKey)]", value)
            }
        } else if let array = value as? [AnyObject] {
            for value in array {
                components += queryComponents("\(key)[]", value)
            }
        } else {
            components.append((escape(key), escape("\(value)")))
        }
        
        return components
    }
    
    /**
     Returns a percent-escaped string following RFC 3986 for a query string key or value.
     
     RFC 3986 states that the following characters are "reserved" characters.
     
     - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
     - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
     
     In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
     query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
     should be percent-escaped in the query string.
     
     - parameter string: The string to be percent-escaped.
     
     - returns: The percent-escaped string.
     */
    public func escape(string: String) -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        let allowedCharacterSet = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as! NSMutableCharacterSet
        allowedCharacterSet.removeCharactersInString(generalDelimitersToEncode + subDelimitersToEncode)
        
        var escaped = ""
        
        //==========================================================================================================
        //
        //  Batching is required for escaping due to an internal bug in iOS 8.1 and 8.2. Encoding more than a few
        //  hundred Chinense characters causes various malloc error crashes. To avoid this issue until iOS 8 is no
        //  longer supported, batching MUST be used for encoding. This introduces roughly a 20% overhead. For more
        //  info, please refer to:
        //
        //      - https://github.com/Alamofire/Alamofire/issues/206
        //
        //==========================================================================================================
        
        
        let batchSize = 50
        var index = string.startIndex
        
        while index != string.endIndex {
            let startIndex = index
            let endIndex = index.advancedBy(batchSize, limit: string.endIndex)
            let range = Range(start: startIndex, end: endIndex)
            
            let substring = string.substringWithRange(range)
            
            escaped += substring.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacterSet) ?? substring
            
            index = endIndex
            
        }
        
        return escaped
    }
}
