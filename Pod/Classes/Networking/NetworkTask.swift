
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


public struct DataUploadTask: NetworkUploadRequest {
    
    public let urlRequest: NSURLRequest

    public let name: String
    
    public let fileName: String
    
    public let mimeType: String
    
    let taskCompletion: DataResponseCompletion

    public init(urlRequest: NSURLRequest, name: String, fileName: String, mimeType: String, taskCompletion: DataResponseCompletion) {
        
        self.urlRequest = urlRequest
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
        self.taskCompletion = taskCompletion
    }
    
    public func handleResponse(dataOptional: NSData?, errorOptional: NSError?) {
        
        self.taskCompletion(dataOptional: dataOptional, errorOptional: errorOptional)
    }
}

public struct DataUploadJsonResponseTask: NetworkUploadRequest {
    
    public let urlRequest: NSURLRequest
    
    public let name: String
    
    public let fileName: String
    
    public let mimeType: String
    
    let taskCompletion: JSONResponseCompletion
    
    public init(urlRequest: NSURLRequest, name: String, fileName: String, mimeType: String,  taskCompletion: JSONResponseCompletion) {
        
        self.urlRequest = urlRequest
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
        self.taskCompletion = taskCompletion
    }
    
    public func handleResponse(dataOptional: NSData?, errorOptional: NSError?) {
        
        let (json, jsonError) = convertResponseToJson(dataOptional)
        
        let error: NSError? = jsonError == nil ? errorOptional : jsonError
        
        self.taskCompletion(responseOptional: json, errorOptional: error)

    }
}

public struct DataDownloadTask: NetworkDownloadRequest {
 
    public var urlRequest: NSURLRequest
    public let downloadModel: MODownloadModel
    public let downloadFileDestinationComplertionHandler: DownloadDestinationCompletion
    public let downloadProgressCompletion: DownloadProgressCompletion
    public let downloadCompletion: ErrorCompletion
    
    public init(downloadModel: MODownloadModel, downloadFileDestinationComplertionHandler: DownloadDestinationCompletion, downloadProgressCompletion: DownloadProgressCompletion, downloadCompletion: ErrorCompletion) {
        
        self.downloadModel = downloadModel
        
        self.urlRequest = downloadModel.request!
        
        self.downloadFileDestinationComplertionHandler = downloadFileDestinationComplertionHandler
        
        self.downloadProgressCompletion = downloadProgressCompletion

        self.downloadCompletion = downloadCompletion

    }
    
    public func handleResponse(dataOptional: NSData?, errorOptional: NSError?) {
        
        downloadCompletion(errorOptional: errorOptional)
        
    }
    
    public func handleDownloadLocation(fileLocation: NSURL) -> NSURL {
        
        return downloadFileDestinationComplertionHandler(donwloadFileTemporaryLocation: fileLocation)
        
    }
    
    public func handleDownloadProgress(bytesRead: Int64, totalBytesRead: Int64, totalBytesExpectedToRead: Int64) {
        
        return downloadProgressCompletion(bytesRead: bytesRead, totalBytesRead: totalBytesRead, totalBytesExpectedToRead: totalBytesExpectedToRead)
        
    }
    
}

public struct DownloadRequest: NetworkRequest {
    
    public var urlRequest: NSURLRequest
    
    init(urlRequest: NSURLRequest) {
        
        self.urlRequest = urlRequest
        
    }
    
    public func handleResponse(dataOptional: NSData?, errorOptional: NSError?) {
        
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
        
        let (json, jsonError) = convertResponseToJson(dataOptional)
        
        let error: NSError? = jsonError == nil ? errorOptional : jsonError

        self.taskCompletion(responseOptional: json, errorOptional: error)
    }
}

extension NetworkRequest {
    
    public func convertResponseToJson(dataOptional: NSData?) -> (AnyObject?, NSError?) {
        
        var json: AnyObject?
        var jsonError: NSError?

        if let data = dataOptional {
        
            do {
            
                json = try NSJSONSerialization.JSONObjectWithData(data, options: [NSJSONReadingOptions.MutableLeaves, NSJSONReadingOptions.MutableContainers])
            } catch let error as NSError {
                jsonError = error
                json = nil
            }
        }
        
        return (json, jsonError)
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