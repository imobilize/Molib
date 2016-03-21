
import Foundation



//mark Network Implementations

let kNetworkServiceClass = "NetworkService"

class NetworkServiceFactory {
    
    private static var serviceInstance: NetworkService?
    private static var authenticatedNetworkServiceInstance: AuththenticatedNetworkService?
    
    static func networkService() -> NetworkService {
        
        if serviceInstance == nil {
            
            serviceInstance = setupNetworkService()
        }
        
        return serviceInstance!
    }
    
    static func authenticatedNetworkService() -> AuththenticatedNetworkService {
        
        if authenticatedNetworkServiceInstance == nil {
            
            let userDefaults = UserDefaultsImpl()
            
            authenticatedNetworkServiceInstance = AuththenticatedNetworkService(networkService: networkService(), userDefaults: userDefaults)
        }
        
        return authenticatedNetworkServiceInstance!
    }
    
    private static func setupNetworkService() -> NetworkService {
        
        let networkService: NetworkService
        
        let infoDictionary = NSBundle.mainBundle().infoDictionary
        
        let networkClass = infoDictionary![kNetworkServiceClass] as? String ?? "NetworkService"
        
        switch(networkClass) {
            
        case "MockNetworkServiceImpl":
            
            networkService = MockNetworkService()
            
            break
            
        default:
            
            networkService = AlamoFireNetworkService()
            
        }
        
        return networkService
    }
}