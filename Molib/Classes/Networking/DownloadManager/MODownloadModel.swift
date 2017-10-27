import Foundation
import CoreData

public enum DownloadTaskStatus: String {
    
    case GettingInfo = "GettingInfo"
    case Downloading = "Downloading"
    case Paused = "Paused"
    case Failed = "Failed"
    case Finished = "Finished"
    
}

public struct MODownloadModel: Storable {
    
    public let fileName: String?
    public let fileURL: String?
    public var downloadOperation: NetworkDownloadOperation?
    
    //MARK: Storable Protocol
    
    public var id: String?
    
    public static var typeName = "MODownloadModel"
    
    public init(dictionary: StorableDictionary) {
        
        self.id = dictionary[DownloadModelAttributes.id.rawValue] as? String
        
        self.fileName = dictionary[DownloadModelAttributes.fileName.rawValue] as? String
        
        self.fileURL = dictionary[DownloadModelAttributes.fileURL.rawValue] as? String
                
    }
    
    public func toDictionary() -> [String : AnyObject] {
        
        var dictionary: StorableDictionary = [:]
        
        dictionary[DownloadModelAttributes.id.rawValue] = self.id as AnyObject
        
        dictionary[DownloadModelAttributes.fileName.rawValue] = self.fileName as AnyObject
        
        dictionary[DownloadModelAttributes.fileURL.rawValue] = self.fileURL as AnyObject
        
        return dictionary
        
    }
    
    
//    public var downloadable: Downloadable?
//    public var downloadTask: DataDownloadTask?
//    public var request: NSURLRequest?
//    public var progressFraction: Float?
//    public var progress: (bytesRead: Int64, totalBytesRead: Int64, totalBytesExpectedToRead: Int64)?
    
}

enum DownloadModelAttributes: String {
    
    case id = "id"
    case fileName = "fileName"
    case fileURL = "fileURL"
    case operation = "operation"
    
}
