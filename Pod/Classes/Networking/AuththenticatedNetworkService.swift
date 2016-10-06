
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
        
        let taskCompletion = authenticatedCheckResponseHandler(request)
        
        let authenticatedCheckTask = DataRequestTask(urlRequest: request.urlRequest, taskCompletion: taskCompletion)
        
        let operation = networkService.enqueueNetworkRequest(authenticatedCheckTask)
        
        return operation
    }
    
    public func enqueueNetworkUploadRequest(request: NetworkUploadRequest, fileURL: NSURL) -> UploadOperation? {
        
        let taskCompletion = authenticatedCheckResponseHandler(request)
        
        let authenticatedCheckTask = DataUploadTask(urlRequest: request.urlRequest, name: request.name, fileName: request.fileName, mimeType: request.mimeType, taskCompletion: taskCompletion)
        
        let operation = networkService.enqueueNetworkUploadRequest(authenticatedCheckTask, fileURL: fileURL)
        
        return operation
        
    }
    
    public func enqueueNetworkUploadRequest(request: NetworkUploadRequest, data: NSData) -> UploadOperation? {
        
        let taskCompletion = authenticatedCheckResponseHandler(request)
        
        let authenticatedCheckTask = DataUploadTask(urlRequest: request.urlRequest, name: request.name, fileName: request.fileName, mimeType: request.mimeType, taskCompletion: taskCompletion)
        
        let operation = networkService.enqueueNetworkUploadRequest(authenticatedCheckTask, data: data)
        
        return operation
    }
    
    public func enqueueNetworkDownloadRequest(request: NetworkDownloadRequest) -> DownloadOperation? {
        
        return nil
        
    }
    
    //    public func enqueueNetworkDownloadRequest(request: NetworkDownloadRequest) -> DownloadOperation? {
    //
    //        let taskCompletion: ErrorCompletion = { errorOptional in
    //
    //        }
    //
    //        let downloadCompletion: DownloadCompletion = { fileLocation in
    //
    //        }
    //
    //        let progressCompletion: DownloadProgressCompletion = {_,_,_ in
    //
    //        }
    //
    //        return nil
    //
    //    }
    
    func authenticatedCheckResponseHandler(request: NetworkRequest) -> DataResponseCompletion {
        
        let taskCompletion: DataResponseCompletion = {
            
            (dataOptional: NSData?, errorOptional: NSError?)  in
            
            if let error = errorOptional {
                
                let refreshToken = self.userDefaults.secureStringForKey(kRefreshTokenKey)
                
                if error.code == 401 {
                    
                    let shouldRefresh = self.delegate?.authenticatedNetworkServiceShouldReAuthenticate(self)
                    
                    if shouldRefresh == true && refreshToken != nil {
                        
                        self.handleAuthtenticationErrorForTask(request)
                        
                    } else {
                        
                        request.handleResponse(dataOptional, errorOptional: errorOptional)
                    }
                    
                    
                } else {
                    
                    request.handleResponse(dataOptional, errorOptional: errorOptional)
                }
            } else {
                
                request.handleResponse(dataOptional, errorOptional: errorOptional)
            }
        }
        
        return taskCompletion
    }
    
    func handleAuthtenticationErrorForTask(networkRequest: NetworkRequest) {
        
        let refreshToken = userDefaults.secureStringForKey(kRefreshTokenKey)
        let profileID = userDefaults.secureStringForKey(kProfileID)
        
        if let token = refreshToken {
            
            var refreshTokenParameters = [kRefreshTokenKey: token]
            
            if profileID != nil {
                refreshTokenParameters[kProfileID] = profileID
            }
            
            let refreshTokenURL = self.delegate!.authenticatedNetworkServiceURLForAuthentication(self)
            
            if let request = NSURLRequest.POSTRequestJSON(refreshTokenURL, bodyParameters: refreshTokenParameters) {
                
                let taskCompletion = refreshTokenResponseHandler(networkRequest)
                
                let authenticationTask = JSONRequestTask(urlRequest: request, taskCompletion: taskCompletion)
                
                networkService.enqueueNetworkRequest(authenticationTask)
            }
        } else {
            
            let userInfo = [NSLocalizedDescriptionKey: "User not authenticated to use this service"]
            
            let error = NSError(domain: "Authenticated Service", code: 101, userInfo: userInfo)
            
            networkRequest.handleResponse(nil, errorOptional: error)
        }
    }
    
    func refreshTokenResponseHandler(initialNetworkRequest: NetworkRequest) -> JSONResponseCompletion {
        
        let refreshToken = userDefaults.secureStringForKey(kRefreshTokenKey)
        
        let taskCompletion: JSONResponseCompletion = {
            
            (responseOptional: AnyObject?, errorOptional: NSError?) in
            
            if errorOptional == nil {
                
                self.delegate!.authenticatedNetworkService(self, didReauthenticateWithToken: refreshToken!)
                
                self.networkService.enqueueNetworkRequest(initialNetworkRequest)
                
            } else {
                
                self.delegate!.authenticatedNetworkService(self, failedToAuthenticateWithToken: refreshToken!)
                
                initialNetworkRequest.handleResponse(nil, errorOptional: errorOptional)
            }
        }
        
        return taskCompletion
    }
    
}
