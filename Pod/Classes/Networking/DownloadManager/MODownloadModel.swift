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
    public var startTime: NSDate!
    public var status: String {
    
        didSet {
            
            delegate?.downloadStatusDidUpdate(status)
            
        }
        
    }
    
    public var downloadable: Downloadable?
    public var downloadTask: DataDownloadTask?
    public var request: NSURLRequest?
    
    public var delegate: MODownloadModelDelegate?
    
    public var progressFraction: Float?
    public var progress: (bytesRead: Int64, totalBytesRead: Int64, totalBytesExpectedToRead: Int64)? {
        
        didSet {
        
            progressFraction = (Float(progress!.totalBytesRead) / Float(progress!.totalBytesExpectedToRead))
            
            delegate?.downloadRequestDidUpdateProgress(progressFraction!)

            
        }
        
    }
    
    public init(fileName: String, fileURL: String) {
        
        self.status = DownloadTaskStatus.GettingInfo.rawValue
        
        self.fileName = fileName
        
        self.fileURL = fileURL
        
    }
    
}
