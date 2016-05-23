import Foundation

public enum DownloadTaskStatus: String {
    
    case GettingInfo = "GettingInfo"
    case Downloading = "Downloading"
    case Paused = "Paused"
    case Failed = "Failed"
    case Finished = "Finished"
    
}

public class MODownloadModel: NSObject {
    
    public var fileName: String!
    public var fileURL: String!
    public var status: String = DownloadTaskStatus.GettingInfo.rawValue
    
    public var asset: Asset?
    public var downloadTask: DataDownloadTask?
    public var request: NSURLRequest?
    
    public var startTime: NSDate?
    
    public var progressFraction: Float?
    public var progress: (bytesRead: Int64, totalBytesRead: Int64, totalBytesExpectedToRead: Int64)? {
        
        didSet {
        
            progressFraction = (Float(progress!.totalBytesRead) / Float(progress!.totalBytesExpectedToRead))

        }
        
    }
    
    public init(fileName: String, fileURL: String) {
        
        self.fileName = fileName
        
        self.fileURL = fileURL
        
    }
    
}
