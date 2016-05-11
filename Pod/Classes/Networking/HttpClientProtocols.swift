
import Foundation
import UIKit


public protocol Operation {
    
    func cancel()
}

public protocol UploadOperation: Operation {
    
    func pause()
    
    func resume()
    
    func registerProgressUpdate(progressUpdate: ProgressUpdate)
}

public protocol DownloadOperation: Operation {
    
    
}

public protocol NetworkRequest {
    
    var urlRequest: NSURLRequest { get }
    
    func handleResponse(dataOptional: NSData?, errorOptional: NSError?)
}

public protocol NetworkUploadRequest: NetworkRequest {
    
    var name: String { get }
    
    var fileName: String { get }
    
    var mimeType: String { get }
}

public protocol NetworkDownloadRequest: NetworkRequest {
    
    var destinationFileName: String { get }
    
    func handleDownloadResponse(fileLocaion: NSURL, URLResponse: NSURLResponse)
    
}

public protocol NetworkService {
    
    func enqueueNetworkRequest(request: NetworkRequest) -> Operation?
    
    func enqueueNetworkUploadRequest(request: NetworkUploadRequest, data: NSData) -> UploadOperation?

    func enqueueNetworkUploadRequest(request: NetworkUploadRequest, fileURL: NSURL) -> UploadOperation?
    
    func enqueueNetworkDownloadRequest(request: NetworkDownloadRequest) -> DownloadOperation?
    
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
    
    func completionForDownloadRequest(request: NetworkDownloadRequest) -> DownloadCompletion {
        
        let completion = { (fileLocaion: NSURL, URLResponse: NSURLResponse) -> Void in
            
            request.handleDownloadResponse(fileLocaion, URLResponse: URLResponse)
            
        }
        
        return completion
    }
}

public protocol ImageService {
    
    func enqueueImageRequest(request: ImageRequest) -> Operation
    
    func enqueueImageRequestRefreshingCache(request: ImageRequest) -> Operation

}

public protocol ImageRequest {
    
    var urlRequest: NSURLRequest { get }

    func handleResponse(imageURL: String, image: UIImage?, error: NSError?)

}

public protocol MOConnectionHelper {
    
    func relativeURLStringForKey(key:String) -> String
    
    func absoluteURLStringForKey(key: String) -> String
    
    func absoluteURLForKey(key: String) -> NSURL

}