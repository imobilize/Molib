
import Foundation
import UIKit

struct DataRequestTask: NetworkRequest {
    
    let urlRequest: NSURLRequest
    
    let taskCompletion: DataResponseCompletion
    
    init(urlRequest: NSURLRequest, taskCompletion: DataResponseCompletion) {
        
        self.urlRequest = urlRequest
        self.taskCompletion = taskCompletion
    }
    
    
    func handleResponse(dataOptional: NSData?, errorOptional: NSError?) {
        
        self.taskCompletion(dataOptional: dataOptional, errorOptional: errorOptional)
    }
}


struct JSONRequestTask: NetworkRequest {
    
    let log = LoggerFactory.logger()

    let urlRequest: NSURLRequest
    
    let taskCompletion: JSONResponseCompletion
    
    init(urlRequest: NSURLRequest, taskCompletion: JSONResponseCompletion) {
        
        self.urlRequest = urlRequest
        self.taskCompletion = taskCompletion
    }
    
    
    func handleResponse(dataOptional: NSData?, errorOptional: NSError?) {
        
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

struct ImageRequestTask: ImageRequest {
    
    let urlRequest: NSURLRequest

    let taskCompletion: ImageResponseCompletion
    
    
    init(urlRequest: NSURLRequest, taskCompletion: ImageResponseCompletion) {
        
        self.urlRequest = urlRequest
        self.taskCompletion = taskCompletion
    }
    
    
    func handleResponse(imageURL: String, image: UIImage?, error: NSError?) {
    
        self.taskCompletion(imageURL: imageURL, image: image, error: error)
    }
}