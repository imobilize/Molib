
import Foundation
import UIKit


protocol Operation {
    
    func cancel()
}

protocol UploadOperation: Operation {
    
    func pause()
    
    func resume()
    
    func registerProgressUpdate(progressUpdate: ProgressUpdate)
}

protocol NetworkRequest {
    
    var urlRequest: NSURLRequest { get }
    
    func handleResponse(dataOptional: NSData?, errorOptional: NSError?)
}

protocol NetworkService {
    
    func enqueueNetworkRequest(request: NetworkRequest) -> Operation?
    
    func enqueueNetworkUploadRequest(request: NetworkRequest, fileURL: NSURL) -> UploadOperation?
    
    func enqueueNetworkUploadRequest(request: NetworkRequest, data: NSData) -> UploadOperation?

}

extension NetworkService {
    
    func completionForRequest(request: NetworkRequest) -> DataResponseCompletion {
        
        let completion = { (dataOptional: NSData?, errorOptional: NSError?) -> Void in
            
            if dataOptional == nil && errorOptional == nil {
                
                let userInfo = [NSLocalizedDescriptionKey: "Invalid response"]
                
                let error = NSError(domain: "NetworkService", code: 101, userInfo: userInfo)
                
                request.handleResponse(dataOptional, errorOptional: error)
                
            } else {
                
                request.handleResponse(dataOptional, errorOptional: errorOptional)
            }
        }
        
        return completion
    }
}

protocol ImageService {
    
    func enqueueImageRequest(request: ImageRequest) -> Operation
    
    func enqueueImageRequestBypassingCached(request: ImageRequest) -> Operation

}

protocol ImageRequest {
    
    var urlRequest: NSURLRequest { get }

    func handleResponse(imageURL: String, image: UIImage?, error: NSError?)

}

protocol MOConnectionHelper {
    
    func relativeURLStringForKey(key:String) -> String
    
    func absoluteURLStringForKey(key: String) -> String
    
    func absoluteURLForKey(key: String) -> NSURL

}