import Foundation
import Alamofire

let kServiceErrorCode = 501

class AlamoFireNetworkService : NetworkService {
    
    private var manager: SessionManager!
    
    init() {
        
        self.manager = SessionManager.`default`
    }
    
    func enqueueNetworkRequest(request: NetworkRequest) -> Operation? {
        
        let alamoFireRequest = self.manager.request(request.urlRequest)
        
        let alamoFireRequestOperation = AlamoFireRequestOperation(request: alamoFireRequest)
        
        let completion = completionForRequest(request: request)
        
        alamoFireRequestOperation.fire(completion: completion)
        
        return alamoFireRequestOperation
    }
    
    func enqueueNetworkUploadRequest(request: NetworkUploadRequest, data: Data) -> UploadOperation? {
                
        let method = HTTPMethod(rawValue: request.urlRequest.httpMethod!.uppercased())
        
        let dataResponseCompletion = completionForRequest(request: request)
        
        var alamoFireUploadOperation = AlamoFireUploadOperation(dataCompletion: dataResponseCompletion)
        
        self.manager.upload(method!, request.urlRequest.url!.absoluteString, multipartFormData: { (formData: MultipartFormData) in
            
            formData.append(data, withName: request.name, mimeType: request.mimeType)

            }, encodingCompletion: alamoFireUploadOperation.handleEncodingCompletion())
        
        return alamoFireUploadOperation
    }
    
    func enqueueNetworkUploadRequest(request: NetworkUploadRequest, fileURL: URL) -> UploadOperation? {
        
        let method = HTTPMethod(rawValue: request.urlRequest.httpMethod!.uppercased())
        
        let dataResponseCompletion = completionForRequest(request: request)
        
        var alamoFireUploadOperation = AlamoFireUploadOperation(dataCompletion: dataResponseCompletion)
        
        self.manager.upload(method!, request.urlRequest.url!.absoluteString, multipartFormData: { (formData: MultipartFormData) in
            
            formData.append(fileURL, withName: request.name, fileName: request.fileName, mimeType: request.mimeType)

        }, encodingCompletion: alamoFireUploadOperation.handleEncodingCompletion())
        
        return alamoFireUploadOperation
    }
        
    func enqueueNetworkDownloadRequest(request: NetworkDownloadRequest) -> DownloadOperation? {
        
        let method = HTTPMethod(rawValue: request.urlRequest.httpMethod!.uppercased())
        
        let downloadProgress = completionForDownloadProgress(request: request)
        
        let downloadLocationCompletion = completionForDownloadLocation(request: request)
        
        let downloadCompletion = completionForDownloadRequest(request: request)
        
        var alamoFireDownloadOperation = AlamoFireDownloadOperation(downloadProgress: downloadProgress, downloadLocationCompletion: downloadLocationCompletion, downloadCompletion: downloadCompletion)
        
        alamoFireDownloadOperation.request = self.manager.download(request.urlRequest as! URLConvertible, method: method!, parameters: nil, encoding: URLEncoding.`default`, headers: nil, to: alamoFireDownloadOperation.handleDownloadLocation)

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
        
        request.validate().responseData { (networkResponse) -> Void in
            
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
    
    
    init(dataCompletion: @escaping DataResponseCompletion) {
        
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
    
    
        uploadRequest?.validate().responseData { (networkResponse: Response<Data, Error>) -> Void in
    
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
    internal var request: Request?
    
    private let downloadLocationCompletion: DownloadLocationCompletion
    private let downloadProgress: DownloadProgress
    private let downloadCompletion: ErrorCompletion
    
    init(downloadProgress: @escaping DownloadProgress, downloadLocationCompletion: @escaping DownloadLocationCompletion, downloadCompletion: @escaping ErrorCompletion) {
        
        self.downloadProgress = downloadProgress
        self.downloadLocationCompletion = downloadLocationCompletion
        self.downloadCompletion = downloadCompletion
        
    }

    private func handleDownloadProgress(bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        downloadProgress(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite)
        
    }
    
    private func handleDownloadLocation(temporaryURL: URL, urlResponse: HTTPURLResponse) -> URL {
        
        return downloadLocationCompletion(temporaryURL)
    }
    
    private func handleDownloadCompletion(downladRequest: URLRequest?, downloadResponse: HTTPURLResponse?, data: Data?, error: Error?) {
        
        downloadCompletion(error as! NSError)
        
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
    
    func handleResponse(networkResponse: Response<Data, Error>, completion: DataResponseCompletion) {
        
        var errorOptional: Error? = nil
        
        switch networkResponse.result {
            
        case .Success:
            
            let response = networkResponse.response!
            
            self.log.info("Received succses response \(response.statusCode)")
            
        case .Failure(let error):
            
            if let response = networkResponse.response {
                
                self.log.info("Received error response \(response.statusCode)")
                
                let errorMessage = NSLocalizedString("The service is currently unable to satisfy your request. Please try again later", comment: "Bad service response text")

                let userInfo = ["response": response, NSUnderlyingErrorKey: error, ]
                
                errorOptional = Error(domain: "RequestOperation", code: response.statusCode, userInfo: userInfo)
                
            } else {
                
                self.log.info("Service is currently down. Received no data")

                let errorMessage = NSLocalizedString("The service is currently unavailable. Please try again later", comment: "Service unavailable text")
                
                let userInfo = [NSUnderlyingErrorKey: error, NSLocalizedDescriptionKey: errorMessage]
                
                errorOptional = Error(domain: "RequestOperation", code: kServiceErrorCode, userInfo: userInfo)
            }
        }
        
        completion(dataOptional: networkResponse.data, errorOptional: errorOptional)
        
    }
}
