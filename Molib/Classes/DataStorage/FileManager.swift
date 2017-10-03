
import Foundation
import UIKit

public protocol LocalFileManager {
    
    func removeItemAtPath(file: String) -> NSError?
}


public class LocalFileManagerImpl: LocalFileManager {
    
    var defaultFileManager: FileManager
    
    public init() {
        defaultFileManager = FileManager.`default`
    }
    
    public func removeItemAtPath(file: String) -> NSError? {
        
        var fileError: NSError? = nil
        
        do {
        
            let fileURL = URL(fileURLWithPath: file, isDirectory: false)

            try defaultFileManager.removeItem(at: fileURL)
            
        } catch let error as NSError {
            
            if error.code != CocoaError.FileNoSuchFileError.rawValue {
                
                fileError = error
            }
        }
        
        return fileError
    }
}
