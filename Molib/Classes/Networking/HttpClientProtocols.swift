
import Foundation
import UIKit

public enum ServiceFailure: Int {
    
    case GeneralError = 101
    
    public var code: Int {
        
        switch self {
        case .GeneralError:
            return 101
        default:
            100
        }
    }
}

public protocol Operation {
    
    func cancel()
}

public protocol UploadOperation: Operation {
    
    func pause()
    
    func resume()
    
    func registerProgressUpdate(progressUpdate: ProgressUpdate)
}

public protocol DownloadOperation: Operation {
    
    func pause()
    
    func resume()
    
}

public protocol NetworkRequest {
    
    var urlRequest: URLRequest { get }
    
    func handleResponse(dataOptional: Data?, errorOptional: Error?)
}

public protocol NetworkUploadRequest: NetworkRequest {
    
    var name: String { get }
    
    var fileName: String { get }
    
    var mimeType: String { get }
}

public protocol NetworkDownloadRequest: NetworkRequest {
    
    var downloadModel: MODownloadModel? { get }
    
    func handleDownloadLocation(fileLocation: URL) -> URL
    
    func handleDownloadProgress(bytesRead: Int64, totalBytesRead: Int64, totalBytesExpectedToRead: Int64) -> Void
    
}

public protocol NetworkService {
    
    func enqueueNetworkRequest(request: NetworkRequest) -> Operation?
    
    func enqueueNetworkUploadRequest(request: NetworkUploadRequest, data: Data) -> UploadOperation?

    func enqueueNetworkUploadRequest(request: NetworkUploadRequest, fileURL: URL) -> UploadOperation?
    
    func enqueueNetworkDownloadRequest(request: NetworkDownloadRequest) -> DownloadOperation?
    
}

extension NetworkService {
    
    func completionForRequest(request: NetworkRequest) -> DataResponseCompletion {
        
        let completion = { (dataOptional: Data?, errorOptional: Error?) -> Void in
            
            if dataOptional == nil && errorOptional == nil {
                
                let userInfo = [NSLocalizedDescriptionKey: "Invalid response"]
                
                let error = NSError(domain: "NetworkService", code: 101, userInfo: userInfo)
                
                request.handleResponse(dataOptional: dataOptional, errorOptional: error)
                
            } else {
                
                request.handleResponse(dataOptional: dataOptional, errorOptional: errorOptional)
            }
        }
        
        return completion
    }
    
    func completionForDownloadRequest(request: NetworkDownloadRequest) -> ErrorCompletion {
        
        let completion = { (errorOptional: Error?) in
        
            var error: Error?
            
            if errorOptional != nil {
                
                let userInfo = [NSLocalizedDescriptionKey: "Invalid response"]
                
                error = NSError(domain: "NetworkService", code: 101, userInfo: userInfo)
            }
            
            request.handleResponse(dataOptional: nil, errorOptional: error)

        }
        
        return completion
    }
    
    func completionForDownloadLocation(request: NetworkDownloadRequest) -> DownloadLocationCompletion {
        
        let completion = { (fileLocaion: URL) -> URL in
            
            request.handleDownloadLocation(fileLocation: fileLocaion)
        }
        
        return completion
    }
    
    func completionForDownloadProgress(request: NetworkDownloadRequest) -> DownloadProgress {
        
        let completion = { (bytesRead: Int64, totalBytesRead: Int64, totalBytesExpected: Int64) in
            
            request.handleDownloadProgress(bytesRead: bytesRead, totalBytesRead: totalBytesRead, totalBytesExpectedToRead: totalBytesExpected)
        }
        
        return completion
    }
}

public protocol ImageService {
    
    func enqueueImageRequest(request: ImageRequest) -> Operation
    
    func enqueueImageRequestRefreshingCache(request: ImageRequest) -> Operation
}

public protocol ImageRequest {
    
    var urlRequest: URLRequest { get }

    func handleResponse(imageURL: String, image: UIImage?, error: Error?)
}

public protocol MOConnectionHelper {
    
    func relativeURLStringForKey(key:String) -> String
    
    func absoluteURLStringForKey(key: String) -> String
    
    func absoluteURLForKey(key: String) -> URL
}
