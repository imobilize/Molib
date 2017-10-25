
import Foundation

public let kRefreshTokenKey = "refreshToken"
public let kProfileID = "profileId"


public protocol AuththenticatedNetworkServiceDelegate {
    
    func authenticatedNetworkServiceShouldReAuthenticate(service: AuththenticatedNetworkService) -> Bool
    
    func authenticatedNetworkServiceURLForAuthentication(service: AuththenticatedNetworkService) -> String
    
    func authenticatedNetworkService(service: AuththenticatedNetworkService, didReauthenticateWithToken: String)
    
    func authenticatedNetworkService(service: AuththenticatedNetworkService, failedToAuthenticateWithToken: String)
}

public class AuththenticatedNetworkService: NetworkService {
    
    public var delegate: AuththenticatedNetworkServiceDelegate?
    
    let networkService: NetworkService
    
    let userDefaults: UserDefaults
    
    public init(networkService: NetworkService, userDefaults: UserDefaults) {
        
        self.networkService = networkService
        self.userDefaults = userDefaults
    }
    
    
    public func enqueueNetworkRequest(request: NetworkRequest) -> Operation? {
        
        let taskCompletion = authenticatedCheckResponseHandler(request: request)
        
        let authenticatedCheckTask = DataRequestTask(urlRequest: request.urlRequest, taskCompletion: taskCompletion)
        
        let operation = networkService.enqueueNetworkRequest(request: authenticatedCheckTask)
        
        return operation
    }
    
    public func enqueueNetworkUploadRequest(request: NetworkUploadRequest, fileURL: URL) -> UploadOperation? {
        
        let taskCompletion = authenticatedCheckResponseHandler(request: request)
        
        let authenticatedCheckTask = DataUploadTask(urlRequest: request.urlRequest, name: request.name, fileName: request.fileName, mimeType: request.mimeType, taskCompletion: taskCompletion)
        
        let operation = networkService.enqueueNetworkUploadRequest(request: authenticatedCheckTask, fileURL: fileURL)
        
        return operation
    }
    
    public func enqueueNetworkUploadRequest(request: NetworkUploadRequest, data: Data) -> UploadOperation? {
        
        let taskCompletion = authenticatedCheckResponseHandler(request: request)
        
        let authenticatedCheckTask = DataUploadTask(urlRequest: request.urlRequest, name: request.name, fileName: request.fileName, mimeType: request.mimeType, taskCompletion: taskCompletion)
        
        let operation = networkService.enqueueNetworkUploadRequest(request: authenticatedCheckTask, data: data)
        
        return operation
    }
    
    public func enqueueNetworkDownloadRequest(request: NetworkDownloadRequest) -> DownloadOperation? {
        
        return nil
        
    }
    
    
    func authenticatedCheckResponseHandler(request: NetworkRequest) -> DataResponseCompletion {
        
        let taskCompletion: DataResponseCompletion = {
            
            (dataOptional: Data?, errorOptional: Error?)  in
            
            if let error = errorOptional {
                
                let refreshToken = self.userDefaults.secureStringForKey(key: kRefreshTokenKey)
                
                if (error as NSError).code == 401 {
                    
                    let shouldRefresh = self.delegate?.authenticatedNetworkServiceShouldReAuthenticate(service: self)
                    
                    if shouldRefresh == true && refreshToken != nil {
                        
                        self.handleAuthtenticationErrorForTask(networkRequest: request)
                        
                    } else {
                        
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
        
        let refreshToken = userDefaults.secureStringForKey(key: kRefreshTokenKey)
        let profileID = userDefaults.secureStringForKey(key: kProfileID)
        
        if let token = refreshToken {
            
            var refreshTokenParameters = [kRefreshTokenKey: token]
            
            if profileID != nil {
                refreshTokenParameters[kProfileID] = profileID
            }
            
            let refreshTokenURL = self.delegate!.authenticatedNetworkServiceURLForAuthentication(service: self)
            
            if let request = URLRequest.POSTRequestJSON(refreshTokenURL, bodyParameters: refreshTokenParameters) {
                
                let taskCompletion = refreshTokenResponseHandler(initialNetworkRequest: networkRequest)
                
                let authenticationTask = JSONRequestTask(urlRequest: request, taskCompletion: taskCompletion)
                
                networkService.enqueueNetworkRequest(authenticationTask)
            }
        } else {
            
            let userInfo = [NSLocalizedDescriptionKey: "User not authenticated to use this service"]
            
            let error = NSError(domain: "Authenticated Service", code: 101, userInfo: userInfo)
            
            networkRequest.handleResponse(dataOptional: nil, errorOptional: error)
        }
    }
    
    func refreshTokenResponseHandler(initialNetworkRequest: NetworkRequest) -> JSONResponseCompletion {
        
        let refreshToken = userDefaults.secureStringForKey(key: kRefreshTokenKey)
        
        let taskCompletion: JSONResponseCompletion = {
            
            (responseOptional: AnyObject?, errorOptional: Error?) in
            
            if errorOptional == nil {
                
                self.delegate?.authenticatedNetworkService(service: self, didReauthenticateWithToken: refreshToken!)

                _ = self.networkService.enqueueNetworkRequest(request: initialNetworkRequest)
                
            } else {
                
                self.delegate?.authenticatedNetworkService(service: self, failedToAuthenticateWithToken: refreshToken!)
                
                initialNetworkRequest.handleResponse(dataOptional: nil, errorOptional: errorOptional)
            }
            }
        
        return taskCompletion
    }

}
