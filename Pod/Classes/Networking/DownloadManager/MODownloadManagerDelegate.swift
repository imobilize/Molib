import Foundation

@objc public protocol MODownloadManagerDelegate {
    
    optional func downloadRequestDidUpdateProgress(bytesRead: Int64, totalBytesRead: Int64, totalBytesExpectedToRead: Int64)
    
    optional func downloadRequestStarted(downloadModel: MODownloadModel, index: Int)
    
    optional func downloadRequestPaused(downloadModel: MODownloadModel, index: Int)
    
    optional func downloadRequestedResumed()
    
    optional func downloadRequesteRetry()
    
    optional func downloadRequestCancelled()
    
    optional func downloadRequestFinished(errorOptional: NSError?)
    
    optional func downloadRequestFailed()
    
}

public protocol DownloadManager {
    
    var delegate: MODownloadManagerDelegate? { get set }
    
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