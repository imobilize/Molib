
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

    public func downloadIdentifier() -> String {
        return id
    }

    public func uniqueIdentifier() -> String {
        return id
    }

    public func downloadName() -> String {
        return fileName
    }

    public func url() -> URL {
        return downloadURL
    }

    public func localURL() -> URL {
        return localFileURL
    }

    public var downloadURL: URL

    public var localFileURL: URL

    public var id: String

    public var fileName: String

    public var status: String = TaskStatus.GettingInfo.description()
    
    public var file: (size: Float, unit: String)?
    public var downloadedFile: (size: Float, unit: String)?
    
    public var remainingTime: (hours: Int, minutes: Int, seconds: Int)?
    
    public var speed: (speed: Float, unit: String)?
    
    public var progress: Float = 0
    
    public var task: URLSessionDownloadTask?
    
    public var startTime: Date?
    
    init(id: String, fileName: String, fileURL: URL, destinationFileURL: URL) {

        self.id = id
        self.fileName = fileName
        self.downloadURL = fileURL
        self.localFileURL = destinationFileURL
        
        super.init()
    }
}
