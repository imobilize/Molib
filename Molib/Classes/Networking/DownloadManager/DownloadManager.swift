import Foundation


let MODownloadManagerImplDomain = "DownloadManager"

enum MODownloadManagerErrorCode: Int {
    
    case InvalidURL = 301;
    case InvalidState = 302;
}


public class DownloadServiceFactory {
    
    private static var downloadService: DownloadService!
    
    public class func getDownloadService() -> DownloadService {
        
        if downloadService == nil {

            downloadService = ALDownloadManager()
        }
        
        return downloadService
    }
}

