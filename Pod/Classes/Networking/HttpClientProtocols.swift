
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
    
    func handleDownloadFileLocation(fileLocation: NSURL)
    
    func handleDownloadProgress(bytesRead: Int64, totalBytesRead: Int64, totalBytesExpectedToRead: Int64)
    
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
    
    func completionForDownloadDestination(request: NetworkDownloadRequest) -> DownloadCompletion {
        
        let completion = { (fileLocaion: NSURL) -> Void in
            
            //TODO: Check that the file does not already exist, return saved file location to NetworkDownloadRequest
            
            request.handleDownloadFileLocation(fileLocaion)
            
        }
        
        return completion
    }
    
    func completionForDownloadProgress(request: NetworkDownloadRequest) -> DownloadProgressCompletion {
        
        let completion = { (bytesRead: Int64, totalBytesRead: Int64, totalBytesExpected: Int64) in
            
            //TODO: Convert the progress to relevant format, return to NetworkDownloadRequest
            
            request.handleDownloadProgress(bytesRead, totalBytesRead: totalBytesRead, totalBytesExpectedToRead: totalBytesExpected)
            
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