import Foundation

let kNetworkServiceClass = "NetworkService"

public class NetworkServiceFactory {
    
    private static var serviceInstance: NetworkOperationService?
    private static var authenticatedNetworkServiceInstance: AuththenticatedNetworkService?
    
    public static func networkService() -> NetworkOperationService {
        
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
    
    private static func setupNetworkService() -> NetworkOperationService {
        
        let networkService: NetworkOperationService
        
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
