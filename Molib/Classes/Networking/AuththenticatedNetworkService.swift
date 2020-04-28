
import Foundation

public protocol AuththenticatedNetworkServiceDelegate {
    
    func authenticatedNetworkServiceHeader() -> [String: String]

    func authenticatedNetworkServiceShouldReAuthenticate(service: AuththenticatedNetworkService) -> Bool
    
    func authenticatedNetworkServiceURLRequestForAuthentication(service: AuththenticatedNetworkService) -> URLRequest?
    
    func authenticatedNetworkServiceDidReauthenticate(service: AuththenticatedNetworkService)
    
    func authenticatedNetworkService(service: AuththenticatedNetworkService, failedToAuthenticateWithError: Error)
}

public class AuththenticatedNetworkService: NetworkRequestService {
    
    public var delegate: AuththenticatedNetworkServiceDelegate?
    
    let networkService: NetworkRequestService

    var authHeaders: [String: String]?
    
    public init(networkService: NetworkRequestService) {
        
        self.networkService = networkService
    }

    public func enqueueNetworkRequest(request: NetworkRequest) -> NetworkOperation? {

        let taskCompletion = authenticatedCheckResponseHandler(request: request)

        var authRequest = request.urlRequest

         if let headers = authHeaders ?? delegate?.authenticatedNetworkServiceHeader() {
            authHeaders = headers
            headers.forEach { (key: String, value: String) in
                authRequest.setValue(key, forHTTPHeaderField: value)
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
        
        let taskCompletion = authenticatedCheckResponseHandler(request: request)
        
        var authRequest = request.urlRequest
        
        if let headers = authHeaders ?? delegate?.authenticatedNetworkServiceHeader() {
            authHeaders = headers
            headers.forEach { (key: String, value: String) in
                authRequest.setValue(key, forHTTPHeaderField: value)
            }
        }
        
        let authenticatedCheckTask = DataUploadTask(urlRequest: authRequest, name: request.name, fileName: request.fileName, fileURL: request.fileURL, mimeType: request.mimeType, taskCompletion: taskCompletion)
        
        let operation = networkService.enqueueNetworkUploadRequest(request: authenticatedCheckTask)
        
        return operation
    }
    
    public func enqueueNetworkDownloadRequest(request: NetworkDownloadRequest) -> NetworkDownloadOperation? {

        let taskCompletion = authenticatedCheckResponseHandler(request: request)

        let authenticatedCheckTask = DataDownloadTask(urlRequest: request.urlRequest, downloadLocationURL: request.downloadLocationURL, fileName: request.fileName, taskCompletion: taskCompletion)
        let operation = networkService.enqueueNetworkDownloadRequest(request: authenticatedCheckTask)

        return operation
    }
    
    
    func authenticatedCheckResponseHandler(request: NetworkRequest) -> DataResponseCompletion {
        
        let taskCompletion: DataResponseCompletion = { (dataOptional: Data?, errorOptional: Error?)  in
            
            if let error = errorOptional {

                if (error as NSError).code == 401 {
                    
                    if let shouldRefresh = self.delegate?.authenticatedNetworkServiceShouldReAuthenticate(service: self), shouldRefresh == true {

                        self.handleAuthtenticationErrorForTask(networkRequest: request)
                    } else {
                        
                        self.delegate?.authenticatedNetworkService(service: self, failedToAuthenticateWithError: error)
                        request.handleResponse(dataOptional: dataOptional, errorOptional: errorOptional)
                    }
                } else {
                    
                    request.handleResponse(dataOptional: dataOptional, errorOptional: errorOptional)
                }
            } else {
                
                request.handleResponse(dataOptional: dataOptional, errorOptional: errorOptional)
            }
        }
        
        return taskCompletion
    }
    
    func handleAuthtenticationErrorForTask(networkRequest: NetworkRequest) {

        if let request = delegate?.authenticatedNetworkServiceURLRequestForAuthentication(service: self) {

            let taskCompletion = refreshTokenResponseHandler(initialNetworkRequest: networkRequest)

            let authenticationTask = JSONRequestTask(urlRequest: request, taskCompletion: taskCompletion)

            networkService.enqueueNetworkRequest(request: authenticationTask)

        } else {
            
            let userInfo = [NSLocalizedDescriptionKey: "User not authenticated to use this service"]
            
            let error = NSError(domain: "Authenticated Service", code: 101, userInfo: userInfo)
            
            networkRequest.handleResponse(dataOptional: nil, errorOptional: error)
        }
    }
    
    func refreshTokenResponseHandler(initialNetworkRequest: NetworkRequest) -> JSONResponseCompletion {

        let taskCompletion: JSONResponseCompletion = {
            
            (responseOptional: AnyObject?, errorOptional: Error?) in
            
            if errorOptional == nil {
                
                self.delegate?.authenticatedNetworkServiceDidReauthenticate(service: self)

                _ = self.networkService.enqueueNetworkRequest(request: initialNetworkRequest)
                
            } else {
                
                self.delegate?.authenticatedNetworkService(service: self, failedToAuthenticateWithError: errorOptional!)
                
                initialNetworkRequest.handleResponse(dataOptional: nil, errorOptional: errorOptional)
            }
        }
        
        return taskCompletion
    }
}
