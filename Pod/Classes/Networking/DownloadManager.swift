import Foundation

public class DownloadManager {
    
    private var downloadTask: NSURLSessionDownloadTask?
    
    let networkService: NetworkService
    
    var temporaryNetworkService: AlamoFireNetworkService!
    
    public init(networkService: NetworkService) {
        
        self.networkService = networkService
        
    }
    
    public func startDownload(forResource: Resource) {
    
    }
    
    public func pauseDownload() {
        
    }
    
    public func cancelDownload() {
        
    }
    
    public func deleteDownload() {
        
    }
    
    public func resumeDownload() {
        
        
    }
    
    
    
    
    private func downloadTaskForResource(resource: Resource) -> NSURLSessionDownloadTask? {
        
        if let downloadRequest = NSURLRequest.GETRequest(resource.mediaURL) {
            
            let backgroundSession = configureBackgroundSessionWithId(resource.id)
     
            downloadTask = backgroundSession.downloadTaskWithRequest(downloadRequest)
            
        }
     
        return downloadTask
        
    }
    
    private func configureBackgroundSessionWithId(sessionId: String) -> NSURLSession {
        
        let backgroundSessionConfiguration = NSURLSessionConfiguration.backgroundSessionConfiguration(sessionId)
        
        return NSURLSession(configuration: backgroundSessionConfiguration)
        
    }
    
}

public protocol Resource {
    
    var id: String { get }
    var mediaURL: String { get }
    var resourceLocalURL: NSURL? { get }
    
}