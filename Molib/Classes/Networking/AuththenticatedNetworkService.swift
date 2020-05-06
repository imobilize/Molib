
import Foundation
import Alamofire

public protocol AuththenticatedNetworkServiceDelegate: class {
    
    func authenticatedNetworkServiceHeader() -> [String: String]

    func authenticatedNetworkServiceShouldReAuthenticate(service: AuththenticatedNetworkService) -> Bool
    
    func authenticatedNetworkServiceDidRequestReAuthentication(service: AuththenticatedNetworkService, completion: @escaping ErrorCompletion)
}


public class AuththenticatedNetworkService: NetworkRequestService {
    
    public weak var delegate: AuththenticatedNetworkServiceDelegate?
    
    let networkService: NetworkRequestService
    var retryOperation: NetworkOperation?

    public init(networkService: NetworkRequestService) {
        
        self.networkService = networkService
    }

    public func enqueueNetworkRequest(request: NetworkRequest) -> NetworkOperation? {

        let taskCompletion = authenticatedCheckResponseHandler(initialRequest: request)

        var authRequest = request.urlRequest

         if let headers = delegate?.authenticatedNetworkServiceHeader() {
            headers.forEach { (key: String, value: String) in
                authRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        let authenticatedCheckTask = DataRequestTask(urlRequest: authRequest, taskCompletion: taskCompletion)

        let operation = networkService.enqueueNetworkRequest(request: authenticatedCheckTask)

        return operation
    }

    public func cancelAllOperations() {
        self.networkService.cancelAllOperations()
    }


    public func enqueueNetworkUploadRequest(request: NetworkUploadRequest) -> NetworkUploadOperation? {
        
        let taskCompletion = authenticatedCheckResponseHandler(initialRequest: request)
        
        var authRequest = request.urlRequest
        
        if let headers = delegate?.authenticatedNetworkServiceHeader() {
            headers.forEach { (key: String, value: String) in
                authRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        let authenticatedCheckTask = DataUploadTask(urlRequest: authRequest, name: request.name, fileName: request.fileName, fileURL: request.fileURL, mimeType: request.mimeType, taskCompletion: taskCompletion)
        
        let operation = networkService.enqueueNetworkUploadRequest(request: authenticatedCheckTask)
        
        return operation
    }
    
    public func enqueueNetworkDownloadRequest(request: NetworkDownloadRequest) -> NetworkDownloadOperation? {

        let taskCompletion = authenticatedCheckResponseHandler(initialRequest: request)

        let authenticatedCheckTask = DataDownloadTask(urlRequest: request.urlRequest, downloadLocationURL: request.downloadLocationURL, fileName: request.fileName, taskCompletion: taskCompletion)
        let operation = networkService.enqueueNetworkDownloadRequest(request: authenticatedCheckTask)

        return operation
    }
    
    
    func authenticatedCheckResponseHandler(initialRequest: NetworkRequest) -> DataResponseCompletion {
        
        let taskCompletion: DataResponseCompletion = { (dataOptional: Data?, errorOptional: Error?)  in
                        
            if let error = errorOptional, let networkError = error.asAFError, networkError.responseCode == 401 {

                if let shouldRefresh = self.delegate?.authenticatedNetworkServiceShouldReAuthenticate(service: self), shouldRefresh == true {

                    self.handleReAuthtentication(forRequest: initialRequest)
                    return
                }
            }
                
            initialRequest.handleResponse(dataOptional: dataOptional, errorOptional: errorOptional)
        }
        
        return taskCompletion
    }
    
    func handleReAuthtentication(forRequest initialRequest: NetworkRequest) {

        delegate?.authenticatedNetworkServiceDidRequestReAuthentication(service: self, completion: { [weak self] (errorOptional) in
            
            guard let `self` = self else { return }
            
            if let error = errorOptional {
                
                let userInfo: [String: Any] = [NSLocalizedDescriptionKey: "User not authenticated to use this service. Please logout, then log back in and try again", NSUnderlyingErrorKey: error]
                
                let authError = NSError(domain: "Authenticated Service", code: 101, userInfo: userInfo)
                
                initialRequest.handleResponse(dataOptional: nil, errorOptional: authError)
            } else {
                
                var authRequest = initialRequest.urlRequest

                if let headers = self.delegate?.authenticatedNetworkServiceHeader() {
                      headers.forEach { (key: String, value: String) in
                          authRequest.setValue(value, forHTTPHeaderField: key)
                      }
                }
                
                let dataRequestTask = DataRequestTask(urlRequest: authRequest, taskCompletion: initialRequest.handleResponse)

                self.retryOperation = self.networkService.enqueueNetworkRequest(request: dataRequestTask)
            }
        })
    }
}
