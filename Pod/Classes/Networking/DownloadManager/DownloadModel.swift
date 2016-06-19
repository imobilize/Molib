
import Foundation
import UIKit

public enum TaskStatus: Int {
    case Unknown, GettingInfo, Downloading, Paused, Failed
    
    public func description() -> String {
        switch self {
        case .GettingInfo:
            return "GettingInfo"
        case .Downloading:
            return "Downloading"
        case .Paused:
            return "Paused"
        case .Failed:
            return "Failed"
        default:
            return "Unknown"
        }
    }
}

public class DownloadModel: NSObject, Downloadable {
    
    public var id: String!
    public var fileName: String!
    public var fileURL: String!
    public var status: String = TaskStatus.GettingInfo.description()
    
    public var file: (size: Float, unit: String)?
    public var downloadedFile: (size: Float, unit: String)?
    
    public var remainingTime: (hours: Int, minutes: Int, seconds: Int)?
    
    public var speed: (speed: Float, unit: String)?
    
    public var progress: Float = 0
    
    public var task: NSURLSessionDownloadTask?
    
    public var startTime: NSDate?
    
    init(id: String, fileName: String, fileURL: String) {
     
        super.init()
        
        self.id = id
        self.fileName = fileName
        self.fileURL = fileURL
    }
}