import Foundation

public protocol MODownloadManagerDelegate {
    
    func downloadRequestDidUpdateProgress()
    
    func downloadRequestStarted(downloadModel: MODownloadModel, index: Int)
    
    func downloadRequestPaused(downloadModel: MODownloadModel, index: Int)
    
    func downloadRequestedResumed()
    
    func downloadRequesteRetry()
    
    func downloadRequestCancelled()
    
    func downloadRequestFinished()
    
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