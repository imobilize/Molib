
import UIKit

public class DownloadUtility: NSObject {

    class var fileManager: FileManager {
        get { return FileManager.`default` }
    }

    public static let DownloadCompletedNotif: String = {
        return "com.Downloader.DownloadCompletedNotif"
    }()
    
    public static let baseFilePath: String = {
        return NSHomeDirectory() + "/Documents"
    }()
    
    public class func getUniqueFileNameWithPath(filePath : String) -> String {
        let fileURL = URL(fileURLWithPath: filePath)
        let fileExtension = fileURL.pathExtension
        let fileName = fileURL.deletingPathExtension().lastPathComponent
        var suggestedFileName = fileName
        
        var isUnique            : Bool = false
        var fileNumber          : Int = 0
        
        let fileManger          = self.fileManager
        
        repeat {
            var fileDocDirectoryPath : String?
            
            if fileExtension.count > 0 {
                fileDocDirectoryPath = "\(fileURL.deletingLastPathComponent())/\(suggestedFileName).\(fileExtension)"
            } else {
                fileDocDirectoryPath = "\(fileURL.deletingLastPathComponent)/\(suggestedFileName)"
            }
            
            let isFileAlreadyExists : Bool = fileManger.fileExists(atPath: fileDocDirectoryPath!)
            
            if isFileAlreadyExists {
                fileNumber += 1
                suggestedFileName = "\(fileName)(\(fileNumber))"
            } else {
                isUnique = true
                if fileExtension.count > 0 {
                    suggestedFileName = "\(suggestedFileName).\(fileExtension)"
                }
            }
            
        } while isUnique == false
        
        return suggestedFileName
    }
    
    public class func calculateFileSizeInUnit(contentLength : Int64) -> Float {
        let dataLength : Float64 = Float64(contentLength)
        if dataLength >= (1024.0*1024.0*1024.0) {
            return Float(dataLength/(1024.0*1024.0*1024.0))
        } else if dataLength >= 1024.0*1024.0 {
            return Float(dataLength/(1024.0*1024.0))
        } else if dataLength >= 1024.0 {
            return Float(dataLength/1024.0)
        } else {
            return Float(dataLength)
        }
    }
    
    public class func calculateUnit(contentLength : Int64) -> String {
        if(contentLength >= (1024*1024*1024)) {
            return "GB"
        } else if contentLength >= (1024*1024) {
            return "MB"
        } else if contentLength >= 1024 {
            return "KB"
        } else {
            return "Bytes"
        }
    }
    
    public class func addSkipBackupAttributeToItemAtURL(docDirectoryPath : String) -> Bool {
        let url : NSURL = NSURL(fileURLWithPath: docDirectoryPath as String)
        let fileManager = self.fileManager
        if fileManager.fileExists(atPath: url.path!) {
            
            do {
                try url.setResourceValue(NSNumber(value: true), forKey: URLResourceKey.isExcludedFromBackupKey)
                return true
            } catch let error as NSError {
               debugPrint("Error excluding \(String(describing: url.lastPathComponent)) from backup \(error)")
                return false
            }
            
        } else {
            return false
        }
    }
    
    public class func getFreeDiskspace() -> Int64? {
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        do {
            let systemAttributes = try self.fileManager.attributesOfFileSystem(forPath: documentDirectoryPath.last!)
            let freeSize = systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber
            return freeSize?.int64Value
        } catch let error as NSError {
           debugPrint("Error Obtaining System Memory Info: Domain = \(error.domain), Code = \(error.code)")
            return nil
        }
    }
}
