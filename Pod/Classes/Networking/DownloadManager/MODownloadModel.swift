import Foundation

public enum DownloadTaskStatus: String {
    
    case GettingInfo = "GettingInfo"
    case Downloading = "Downloading"
    case Paused = "Paused"
    case Failed = "Failed"
    
}

public class MODownloadModel: NSObject {
    
    public var fileName: String!
    public var fileURL: String!
    public var status: String = DownloadTaskStatus.GettingInfo.rawValue
    
    public var request: NetworkDownloadRequest?
    
    public var startTime: NSDate?
    
    init(fileName: String, fileURL: String) {
        
        self.fileName = fileName
        
        self.fileURL = fileURL
        
    }
    
}
