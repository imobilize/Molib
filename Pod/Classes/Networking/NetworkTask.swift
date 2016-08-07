
import Foundation
import UIKit
import AVFoundation



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


struct VideoThumbnailRequestOperation: Operation {
    
    var imageGenerator: AVAssetImageGenerator?
    let mediaURL: String
    
    init(mediaURL: String) {
        
        self.mediaURL = mediaURL
        
        if let assetURL = NSURL(string: mediaURL) {
            
            let avAsset = AVURLAsset(URL: assetURL)
            
            imageGenerator = AVAssetImageGenerator(asset: avAsset)
        }
    }
    
    
    func start(completion: ImageResponseCompletion) {
        
        if let generator = imageGenerator {
            
            generator.generateCGImagesAsynchronouslyForTimes([1], completionHandler: { (requestedTime, cgImage, actualTime, AVAssetImageGeneratorResult, error) in
                
                if cgImage != nil {
                    
                    let image = UIImage(CGImage: cgImage!)
                    
                    completion(imageURL: self.mediaURL, image: image, error: error)
                } else {
                    
                    completion(imageURL: self.mediaURL, image: nil, error: error)
                }
                
            })
            
        } else {
            
            let userInfo = [NSLocalizedDescriptionKey: "Invalid media url supplied"]
            
            let error = NSError(domain: "VideoThumbnailRequest", code: ServiceFailure.GeneralError.code, userInfo: userInfo)
            
            completion(imageURL: mediaURL, image: nil, error: error)
        }
    }
    
    func cancel() {
        
        imageGenerator?.cancelAllCGImageGeneration()
    }
}
