
import Foundation
import UIKit

public struct DataRequestTask: NetworkRequest {
    
    public let urlRequest: NSURLRequest
    
    let taskCompletion: DataResponseCompletion
    
    init(urlRequest: NSURLRequest, taskCompletion: DataResponseCompletion) {
        
        self.urlRequest = urlRequest
        self.taskCompletion = taskCompletion
    }
    
    
    public func handleResponse(dataOptional: NSData?, errorOptional: NSError?) {
        
        self.taskCompletion(dataOptional: dataOptional, errorOptional: errorOptional)
    }
}


public struct JSONRequestTask: NetworkRequest {
    
    let log = LoggerFactory.logger()

    public let urlRequest: NSURLRequest
    
    let taskCompletion: JSONResponseCompletion
    
    public init(urlRequest: NSURLRequest, taskCompletion: JSONResponseCompletion) {
        
        self.urlRequest = urlRequest
        self.taskCompletion = taskCompletion
    }
    
    
    public func handleResponse(dataOptional: NSData?, errorOptional: NSError?) {
        
        if let data = dataOptional {
            
            var jsonError: NSError?
            
            let json: AnyObject?
            do {
                json = try NSJSONSerialization.JSONObjectWithData(data, options: [NSJSONReadingOptions.MutableLeaves, NSJSONReadingOptions.MutableContainers])
            } catch let error as NSError {
                jsonError = error
                json = nil
            }
            
            let error: NSError? = jsonError == nil ? errorOptional : jsonError
            
            self.log.verbose("Response: \(json) Error: \(error)" )

            self.taskCompletion(responseOptional: json, errorOptional: error)
            
        } else {
            
            self.taskCompletion(responseOptional: nil, errorOptional: errorOptional)
        }
    }
}

public struct ImageRequestTask: ImageRequest {
    
    public let urlRequest: NSURLRequest

    let taskCompletion: ImageResponseCompletion
    
    
    init(urlRequest: NSURLRequest, taskCompletion: ImageResponseCompletion) {
        
        self.urlRequest = urlRequest
        self.taskCompletion = taskCompletion
    }
    
    
    public func handleResponse(imageURL: String, image: UIImage?, error: NSError?) {
    
        self.taskCompletion(imageURL: imageURL, image: image, error: error)
    }
}