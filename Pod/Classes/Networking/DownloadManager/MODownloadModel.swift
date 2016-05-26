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
            
//            dispatch_async(dispatch_get_main_queue()) { [weak self] in
//                
//                if let instance = self {
//                    
//                    instance.delegate?.downloadStatusDidUpdate(instance.status)
//
//                }
//                
//            }

            delegate?.downloadStatusDidUpdate(status)

            
        }
        
    }
    
    public var asset: Asset?
    public var downloadTask: DataDownloadTask?
    public var request: NSURLRequest?
    
    public var delegate: MODownloadModelDelegate?
    
    public var progressFraction: Float?
    public var progress: (bytesRead: Int64, totalBytesRead: Int64, totalBytesExpectedToRead: Int64)? {
        
        didSet {
        
//            dispatch_async(dispatch_get_main_queue()) { [weak self] in
//                
//                if let instance = self {
//                    
//                    instance.progressFraction = (Float(instance.progress!.totalBytesRead) / Float(instance.progress!.totalBytesExpectedToRead))
//                    
//                    instance.delegate?.downloadRequestDidUpdateProgress(instance.progressFraction!)
//                    
//                }
//                
//            }
            
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
