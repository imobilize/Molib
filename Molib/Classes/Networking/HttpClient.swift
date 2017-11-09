import Foundation

let kNetworkServiceClass = "NetworkService"

public class NetworkServiceFactory {
    
    private static var serviceInstance: NetworkRequestService?
    private static var authenticatedNetworkServiceInstance: AuththenticatedNetworkService?
    
    public static func networkService() -> NetworkRequestService {
        
        if serviceInstance == nil {
            
            serviceInstance = setupNetworkService()
        }
        
        return serviceInstance!
    }
    
    public static func authenticatedNetworkService() -> AuththenticatedNetworkService {
        
        if authenticatedNetworkServiceInstance == nil {

            authenticatedNetworkServiceInstance = AuththenticatedNetworkService(networkService: networkService())
        }
        
        return authenticatedNetworkServiceInstance!
    }
    
    private static func setupNetworkService() -> NetworkRequestService {
        
        let networkService: NetworkRequestService
        
        let infoDictionary = Bundle.main.infoDictionary
        
        let networkClass = infoDictionary![kNetworkServiceClass] as? String ?? "NetworkService"
        
        switch(networkClass) {
            
        case "MockNetworkServiceImpl":
            
            networkService = MockNetworkService()
            
            break
            
        default:
            
            networkService = AlamofireNetworkOperationService()
        }
        
        return networkService
    }
}
