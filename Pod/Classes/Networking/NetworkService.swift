//
//  NetworkService.swift
//  themixxapp
//
//  Created by Andre Barrett on 09/02/2016.
//  Copyright © 2016 MixxLabs. All rights reserved.
//

import Foundation
import Alamofire
import SDWebImage

let kServiceErrorCode = 501

class AlamoFireNetworkService : NetworkService {
    
    private var manager: Manager!
    
    init() {
        
        self.manager = Manager.sharedInstance
    }
    
    func enqueueNetworkRequest(request: NetworkRequest) -> Operation? {
        
        let alamoFireRequest = self.manager.request(request.urlRequest)
        
        let alamoFireRequestOperation = AlamoFireRequestOperation(request: alamoFireRequest)
        
        let completion = completionForRequest(request)
        
        alamoFireRequestOperation.fire(completion)
        
        return alamoFireRequestOperation
    }
    
    func enqueueNetworkUploadRequest(request: NetworkRequest, data: NSData) -> UploadOperation? {
        
        let method = Method(rawValue: request.urlRequest.HTTPMethod!.uppercaseString)
        
        let alamoFireRequest = self.manager.upload(method!, request.urlRequest.URL!.absoluteString, data: data)
        
        return enqueue(request, alamoFireRequest: alamoFireRequest)
    }

    
    func enqueueNetworkUploadRequest(request: NetworkRequest, fileURL: NSURL) -> UploadOperation? {
        
        let method = Method(rawValue: request.urlRequest.HTTPMethod!.uppercaseString)
        
        let alamoFireRequest = self.manager.upload(method!, request.urlRequest.URL!.absoluteString, file: fileURL)
    
        return enqueue(request, alamoFireRequest: alamoFireRequest)
    }
    
    
    private func enqueue(request: NetworkRequest, alamoFireRequest: Request) -> UploadOperation? {
        
        let alamoFireUploadOperation = AlamoFireUploadOperation(request: alamoFireRequest)
        
        let completion = completionForRequest(request)
        
        alamoFireUploadOperation.fire(completion)
        
        return alamoFireUploadOperation

    }
}

struct AlamoFireRequestOperation: Operation {
    
    private let request: Request
    
    init(request: Request) {
        self.request = request
    }
    
    func fire(completion: DataResponseCompletion) {
        
        request.validate().responseData { (networkResponse: Response<NSData, NSError>) -> Void in
        
            self.log.verbose("Request response for URL: \(self.request.request!.URL)")

            self.handleResponse(networkResponse, completion: completion)
        }
    }
    
    func cancel() {
        
        request.cancel()
    }
}


struct AlamoFireUploadOperation : UploadOperation {
    
    private let request: Request
    
    init(request: Request) {
        self.request = request
    }
    
    func fire(completion: DataResponseCompletion) {
        
        request.validate().responseData { (networkResponse: Response<NSData, NSError>) -> Void in
            
            self.log.verbose("Request response for URL: \(self.request.request!.URL)")

            self.handleResponse(networkResponse, completion: completion)
        }
    }

    func registerProgressUpdate(progressUpdate: ProgressUpdate) {
        
        request.progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) -> Void in

            let progress = CGFloat(totalBytesExpectedToWrite)/CGFloat(totalBytesWritten)
            
            progressUpdate(progress: progress)
        }
    }
    
    func pause() {
        request.suspend()
    }
    
    func resume() {
        request.resume()
    }

    func cancel() {
        request.cancel()
    }
}


extension Operation {
    
    var log: Logger { return LoggerFactory.logger() }

    func handleResponse(networkResponse: Response<NSData, NSError>, completion: DataResponseCompletion) {
        
        var errorOptional: NSError? = nil
        
        switch networkResponse.result {
            
        case .Success:
            
            let response = networkResponse.response!
            
            self.log.info("Received succses response \(response.statusCode)")
            
        case .Failure(let error):
            
            if let response = networkResponse.response {
                
                self.log.info("Received error response \(response.statusCode)")
                
                let userInfo = ["response": response, NSUnderlyingErrorKey: error]
                
                errorOptional = NSError(domain: "RequestOperation", code: response.statusCode, userInfo: userInfo)
                
            } else {
                
                let userInfo = [NSUnderlyingErrorKey: error]
                
                errorOptional = NSError(domain: "RequestOperation", code: kServiceErrorCode, userInfo: userInfo)
            }
        }
        
        completion(dataOptional: networkResponse.data, errorOptional: errorOptional)

    }
}

class SDWebImageService: ImageService {
    
    let imageManager = SDWebImageManager.sharedManager()
    
    func enqueueImageRequest(request: ImageRequest) -> Operation {
        
        let operation = imageManager.downloadImageWithURL(request.urlRequest.URL, options: SDWebImageOptions.HighPriority, progress: nil, completed: { (image: UIImage?, error: NSError?, cacheType: SDImageCacheType, success: Bool, url: NSURL!) -> Void in
            
            request.handleResponse(url.URLString, image: image, error: error)
        })
        
        return SDImageOperation(imageOperation: operation)
    }
    
    func enqueueImageRequestBypassingCached(request: ImageRequest) -> Operation {
        
        let operation = imageManager.downloadImageWithURL(request.urlRequest.URL, options: SDWebImageOptions.RefreshCached, progress: nil, completed: { (image: UIImage?, error: NSError?, cacheType: SDImageCacheType, success: Bool, url: NSURL!) -> Void in
            
            request.handleResponse(url.URLString, image: image, error: error)
        })
        
        return SDImageOperation(imageOperation: operation)
    }
}

struct SDImageOperation: Operation {
    
    let imageOperation: SDWebImageOperation
    
    func cancel() {
        imageOperation.cancel()
    }
}
