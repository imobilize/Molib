import Foundation
import Alamofire

extension DownloadRequest {
    
    func downloadProgressValue(value: @escaping (Float)->())  {
        self.downloadProgress { (progress) in
            let completed: Float = Float(progress.completedUnitCount)
            let total: Float = Float(progress.totalUnitCount)
            
            value(completed/total)
        }
    }

}

let ALDownloadNoteCenter = NotificationCenter.default
let ALDownloadedFolderName = "ALDownloadedFolder"

extension Notification.Name {
    public struct Info {
        
        public static let DidResume = Notification.Name(rawValue: "ALDownloadManager.notification.Info.state.didResume")
        
        public static let DidSuspend = Notification.Name(rawValue: "ALDownloadManager.notification.Info.state.didSuspend")

        public static let DidCancel = Notification.Name(rawValue: "ALDownloadManager.notification.Info.state.didCancel")

        public static let DidComplete = Notification.Name(rawValue: "ALDownloadManager.notification.Info.state.didComplete")
    }
}

