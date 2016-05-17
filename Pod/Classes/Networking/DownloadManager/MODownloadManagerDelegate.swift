import Foundation

public protocol MODownloadManagerDelegate {
    
    func downloadRequestDidUpdateProgress(bytesRead: Int64, totalBytesRead: Int64, totalBytesExpectedToRead: Int64)
    
    func downloadRequestStarted(downloadModel: MODownloadModel, index: Int)
    
    func downloadRequestPaused(downloadModel: MODownloadModel, index: Int)
    
    func downloadRequestedResumed()
    
    func downloadRequesteRetry()
    
    func downloadRequestCancelled()
    
    func downloadRequestFinished(errorOptional: NSError?)
    
    func downloadRequestFailed()
    
}

public protocol DownloadManager {
    
    func startDownload(asset: Asset)
    
    func pauseDownload(asset: Asset)
    
    func cancelDownlaod(asset: Asset)
    
    func deleteDownload(asset: Asset)
    
    func resumeDownload(asset: Asset)
    
}

public protocol Asset {
    
    var id: String { get }
    
    var fileName: String { get }
    
    var fileURL: String { get }
    
}