import Foundation

enum DownloadTaskStatus: String {
    
    case GettingInfo = "GettingInfo"
    case Downloading = "Downloading"
    case Paused = "Paused"
    case Failed = "Failed"
    
}

public class MODownloadModel: NSObject {
    
    var fileName: String!
    var fileURL: String!
    var status: String = DownloadTaskStatus.GettingInfo.rawValue
    
    var request: NetworkDownloadRequest?
    
    var startTime: NSDate?
    
    init(fileName: String, fileURL: String) {
        
        self.fileName = fileName
        
        self.fileURL = fileURL
        
    }
    
}
