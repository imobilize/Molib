
import Foundation
import UIKit
import AVFoundation

public struct DataRequestTask: NetworkRequest {
    
    public let urlRequest: URLRequest
    
    let taskCompletion: DataResponseCompletion
    
    init(urlRequest: URLRequest, taskCompletion: @escaping DataResponseCompletion) {
        
        self.urlRequest = urlRequest
        self.taskCompletion = taskCompletion
    }
    
    
    public func handleResponse(dataOptional: Data?, errorOptional: Error?) {
        
        self.taskCompletion(dataOptional, errorOptional)
    }
}

public struct DataDownloadTask: NetworkDownloadRequest {

    public var fileName: String

    public var downloadLocationURL: URL

    public let urlRequest: URLRequest

    let taskCompletion: DataResponseCompletion

    public init(urlRequest: URLRequest, downloadLocationURL: URL, fileName: String, taskCompletion: @escaping DataResponseCompletion) {

        self.urlRequest = urlRequest
        self.downloadLocationURL = downloadLocationURL
        self.fileName = fileName
        self.taskCompletion = taskCompletion
    }

    public func handleResponse(dataOptional: Data?, errorOptional: Error?) {
        self.taskCompletion(dataOptional, errorOptional)
    }
}

public struct DataUploadTask: NetworkUploadRequest {

    public let urlRequest: URLRequest

    public var fileURL: URL

    public let name: String
    
    public let fileName: String
    
    public let mimeType: String
    
    let taskCompletion: DataResponseCompletion

    public init(urlRequest: URLRequest, name: String, fileName: String, fileURL: URL, mimeType: String, taskCompletion: @escaping DataResponseCompletion) {
        
        self.urlRequest = urlRequest
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
        self.fileURL = fileURL

        self.taskCompletion = taskCompletion
    }
    
    public func handleResponse(dataOptional: Data?, errorOptional: Error?) {
        
        self.taskCompletion(dataOptional, errorOptional)
    }
}

public struct DataUploadJsonResponseTask: NetworkUploadRequest {

    public var fileURL: URL
    
    public let urlRequest: URLRequest
    
    public let name: String
    
    public let fileName: String
    
    public let mimeType: String
    
    let taskCompletion: JSONResponseCompletion
    
    public init(urlRequest: URLRequest, name: String, fileName: String, mimeType: String, fileURL: URL, taskCompletion: @escaping JSONResponseCompletion) {
        
        self.urlRequest = urlRequest
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
        self.fileURL = fileURL
        self.taskCompletion = taskCompletion
    }
    
    public func handleResponse(dataOptional: Data?, errorOptional: Error?) {
        
        let (json, jsonError) = convertResponseToJson(dataOptional: dataOptional)
        
        let error: Error? = jsonError == nil ? errorOptional : jsonError
        
        self.taskCompletion(json, error)

    }
}

public struct JSONRequestTask: NetworkRequest {
    
    public let urlRequest: URLRequest
    
    let taskCompletion: JSONResponseCompletion
    
    public init(urlRequest: URLRequest, taskCompletion: @escaping JSONResponseCompletion) {
        
        self.urlRequest = urlRequest
        self.taskCompletion = taskCompletion
    }
    
    
    public func handleResponse(dataOptional: Data?, errorOptional: Error?) {
        
        if errorOptional == nil {
            
            let (json, jsonError) = convertResponseToJson(dataOptional: dataOptional)
            
            let error: Error? = jsonError == nil ? errorOptional : jsonError
            
            self.taskCompletion(json, error)
        } else {
            
            let (json, jsonError) = convertResponseToJson(dataOptional: dataOptional)
            
            if jsonError == nil {
                
                self.taskCompletion(json, errorOptional)

            } else {

                self.taskCompletion(nil, errorOptional)
            }
        }
 
    }
}

extension NetworkRequest {
    
    public func convertResponseToJson(dataOptional: Data?) -> (AnyObject?, Error?) {
        
        var json: AnyObject?
        var jsonError: Error?

        if let data = dataOptional {
        
            do {
            
                let convertedObject = try JSONSerialization.jsonObject(with: data, options: [JSONSerialization.ReadingOptions.mutableLeaves, JSONSerialization.ReadingOptions.mutableContainers])

                json = convertedObject as AnyObject
            } catch let error {
                jsonError = error
                json = nil
            }
        }
        
        return (json, jsonError)
    }
}

public struct ImageRequestTask: ImageRequest {
    
    public let urlRequest: URLRequest

    let taskCompletion: ImageResponseCompletion
    
    
    init(urlRequest: URLRequest, taskCompletion: @escaping ImageResponseCompletion) {
        
        self.urlRequest = urlRequest
        self.taskCompletion = taskCompletion
    }
    
    
    public func handleResponse(imageURL: String, image: UIImage?, error: Error?) {
    
        self.taskCompletion(imageURL, image, error)
    }
}


struct VideoThumbnailRequestOperation: NetworkOperation {
    
    var imageGenerator: AVAssetImageGenerator?
    let mediaURL: String
    
    init(mediaURL: String) {
        
        self.mediaURL = mediaURL
        
        if let assetURL = URL(string: mediaURL) {
            
            let avAsset = AVURLAsset(url: assetURL)
            
            imageGenerator = AVAssetImageGenerator(asset: avAsset)
        }
    }
    
    
    func start(completion: @escaping ImageResponseCompletion) {
        
        if let generator = imageGenerator {
            
            generator.generateCGImagesAsynchronously(forTimes: [NSNumber(value: 1)], completionHandler: { (requestedTime, cgImage, actualTime, AVAssetImageGeneratorResult, error) in
                
                guard let imageRef = cgImage else {
                    completion(self.mediaURL, nil, error)
                    return
                }

                let image = UIImage(cgImage: imageRef)
                    
                completion(self.mediaURL, image, error)
            })
            
        } else {
            
            let userInfo = [NSLocalizedDescriptionKey: "Invalid media url supplied"]
            
            let error = NSError(domain: "VideoThumbnailRequest", code: 101, userInfo: userInfo)
            
            completion(mediaURL, nil, error)
        }
    }
    
    func cancel() {
        
        imageGenerator?.cancelAllCGImageGeneration()
    }
}
