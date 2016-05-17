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
    
//    func enqueueNetworkDownloadRequest(request: NetworkDownloadRequest) -> DownloadOperation? {
//        
//        let method = Method(rawValue: request.urlRequest.HTTPMethod!.uppercaseString)
//        
//        let dataResponseCompletion = completionForDownloadRequest(request)
//        
//        let downloadDestinationCompletion = completionForDownloadDestination(request)
//        
//        let downloadProgressCompletion = completionForDownloadProgress(request)
//        
//        let alamoFireDownloadOperation = AlamoFireDownloadOperation(downloadErrorCompletion: dataResponseCompletion, downloadCompletion: downloadDestinationCompletion, downloadProgressCompletion: downloadProgressCompletion)
//        
//        self.manager.download(method!, request.urlRequest.URL!.absoluteString, destination: alamoFireDownloadOperation.handleDownloadDestination)
//    
//            .progress(alamoFireDownloadOperation.handleDownloadProgress)
//            
//            .response(completionHandler: alamoFireDownloadOperation.handleDownloadCompletion)
//        
//        return alamoFireDownloadOperation
//        
//    }
    
    func enqueueNetworkDownloadRequest(request: NetworkDownloadRequest) -> DownloadOperation? {
        
        let method = Method(rawValue: request.urlRequest.HTTPMethod!.uppercaseString)
        
        let downloadCompletion = completionForDownloadRequest(request)
        
        let downloadFileDestinationHandler = completionForDownloadDestination(request)
        
//            .response(completionHandler: alamoFireDownloadOperation.handleDownloadCompletion)

        return nil
        
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
 
    private let downloadErrorCompletion: ErrorCompletion
    private let downloadDestinationCompletion: DownloadDestinationCompletion
    private let downloadProgressCompletion: DownloadProgressCompletion
    
    init(downloadErrorCompletion: ErrorCompletion, downloadDestinationCompletion: DownloadDestinationCompletion, downloadProgressCompletion: DownloadProgressCompletion) {
        
        self.downloadErrorCompletion = downloadErrorCompletion
        self.downloadDestinationCompletion = downloadDestinationCompletion
        self.downloadProgressCompletion = downloadProgressCompletion
        
    }

    private func handleDownloadProgress(bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        downloadProgressCompletion(bytesRead: bytesWritten, totalBytesRead: totalBytesWritten, totalBytesExpectedToRead: totalBytesExpectedToWrite)
        
    }
    
    private func handleDownloadLocation(temporaryURL: NSURL, urlResponse: NSHTTPURLResponse) -> NSURL {
        
        return downloadDestinationCompletion(donwloadFileTemporaryLocation: temporaryURL)

    }
    
    private func handleDownloadCompletion(downladRequest: NSURLRequest?, downloadResponse: NSHTTPURLResponse?, data: NSData?, error: NSError?) {
        
        downloadErrorCompletion(errorOptional: error)
        
    }
    
    func cancel() {
        
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