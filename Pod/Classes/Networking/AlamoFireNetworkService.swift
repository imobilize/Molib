import Foundation
import Alamofire

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
    
    func enqueueNetworkUploadRequest(request: NetworkUploadRequest, data: NSData) -> UploadOperation? {
                
        let method = Method(rawValue: request.urlRequest.HTTPMethod!.uppercaseString)
        
        let dataResponseCompletion = completionForRequest(request)
        
        var alamoFireUploadOperation = AlamoFireUploadOperation(dataCompletion: dataResponseCompletion)
        
        self.manager.upload(method!, request.urlRequest.URL!.absoluteString, multipartFormData: { (formData: MultipartFormData) in
            
            formData.appendBodyPart(data: data, name: request.name, fileName: request.fileName, mimeType: request.mimeType)
            
            }, encodingCompletion: alamoFireUploadOperation.handleEncodingCompletion())
        
        return alamoFireUploadOperation
    }
    
    func enqueueNetworkUploadRequest(request: NetworkUploadRequest, fileURL: NSURL) -> UploadOperation? {
        
        let method = Method(rawValue: request.urlRequest.HTTPMethod!.uppercaseString)
        
        let dataResponseCompletion = completionForRequest(request)
        
        var alamoFireUploadOperation = AlamoFireUploadOperation(dataCompletion: dataResponseCompletion)
        
        self.manager.upload(method!, request.urlRequest.URL!.absoluteString, multipartFormData: { (formData: MultipartFormData) in
            
            formData.appendBodyPart(fileURL: fileURL, name: request.name, fileName: request.fileName, mimeType: request.mimeType)
            
        }, encodingCompletion: alamoFireUploadOperation.handleEncodingCompletion())
        
        return alamoFireUploadOperation
    }
        
    func enqueueNetworkDownloadRequest(request: NetworkDownloadRequest) -> DownloadOperation? {
        
        let method = Method(rawValue: request.urlRequest.HTTPMethod!.uppercaseString)
        
        let downloadProgress = completionForDownloadProgress(request)
        
        let downloadLocationCompletion = completionForDownloadLocation(request)
        
        let downloadCompletion = completionForDownloadRequest(request)
        
        var alamoFireDownloadOperation = AlamoFireDownloadOperation(downloadProgress: downloadProgress, downloadLocationCompletion: downloadLocationCompletion, downloadCompletion: downloadCompletion)
        
        alamoFireDownloadOperation.request = self.manager.download(method!, request.urlRequest.URLString, destination: alamoFireDownloadOperation.handleDownloadLocation)
        
            .progress(alamoFireDownloadOperation.handleDownloadProgress)
        
            .response(completionHandler: alamoFireDownloadOperation.handleDownloadCompletion)
        
        

        return alamoFireDownloadOperation
        
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
    
    typealias EncodingCompletion = (Manager.MultipartFormDataEncodingResult -> Void)

    private var uploadRequest: Request?
    private let dataCompletion: DataResponseCompletion
    
    
    init(dataCompletion: DataResponseCompletion) {
        
        self.dataCompletion = dataCompletion
    }
    
    mutating func handleEncodingCompletion() -> EncodingCompletion {
        
        return { (encodingResult) in
        
            switch encodingResult {
            
                case .Success(let request, _, _):
            
                    self.uploadRequest = request

                    self.performRequest()
                    
                break
            
                case .Failure(_):
                break
            }
        }
    }

    private func performRequest() {
    
    
        uploadRequest?.validate().responseData { (networkResponse: Response<NSData, NSError>) -> Void in
    
            self.log.verbose("Request response for URL: \(self.uploadRequest!.request!.URL)")
    
            self.handleResponse(networkResponse, completion: self.dataCompletion)
    }

    }
    
    func registerProgressUpdate(progressUpdate: ProgressUpdate) {
        
        if let request = uploadRequest {
            
            request.progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) -> Void in
            
                let progress = CGFloat(totalBytesExpectedToWrite)/CGFloat(totalBytesWritten)
            
                progressUpdate(progress: progress)
                
            }
            
        }
        
    }
    
    func pause() {
        uploadRequest?.suspend()
    }
    
    func resume() {
        uploadRequest?.resume()
    }
    
    func cancel() {
        uploadRequest?.cancel()
    }
}

struct AlamoFireDownloadOperation: DownloadOperation {
 
//    internal let downloadModel: MODownloadModel
    private var request: Request?
    
    private let downloadLocationCompletion: DownloadLocationCompletion
    private let downloadProgress: DownloadProgress
    private let downloadCompletion: ErrorCompletion
    
    init(downloadProgress: DownloadProgress, downloadLocationCompletion: DownloadLocationCompletion, downloadCompletion: ErrorCompletion) {
        
        self.downloadProgress = downloadProgress
        self.downloadLocationCompletion = downloadLocationCompletion
        self.downloadCompletion = downloadCompletion
        
    }

    private func handleDownloadProgress(bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        downloadProgress(bytesRead: bytesWritten, totalBytesRead: totalBytesWritten, totalBytesExpectedToRead: totalBytesExpectedToWrite)
        
    }
    
    private func handleDownloadLocation(temporaryURL: NSURL, urlResponse: NSHTTPURLResponse) -> NSURL {
        
        return downloadLocationCompletion(fileLocation: temporaryURL)

    }
    
    private func handleDownloadCompletion(downladRequest: NSURLRequest?, downloadResponse: NSHTTPURLResponse?, data: NSData?, error: NSError?) {
        
        downloadCompletion(errorOptional: error)
        
    }
    
    func cancel() {
    
        request?.cancel()
        
    }
    
    func resume() {
        
        request?.resume()
        
    }
    
    func pause() {
        
        request?.suspend()
        
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