
import Foundation
import UIKit

public protocol FileManager {
    
    func removeItemAtPath(file: String) -> NSError?
}


public class LocalFileManager: FileManager {
    
    var defaultFileManager: NSFileManager
    
    public init() {
        defaultFileManager = NSFileManager.defaultManager()
    }
    
    public func removeItemAtPath(file: String) -> NSError? {
        
        var fileError: NSError? = nil
        
        do {
        
            let fileURL = NSURL(fileURLWithPath: file, isDirectory: false)

            try defaultFileManager.removeItemAtURL(fileURL)
            
        } catch let error as NSError {
            
            if error.code != NSCocoaError.FileNoSuchFileError.rawValue {
                
                fileError = error
            }
        }
        
        return fileError
    }
}
