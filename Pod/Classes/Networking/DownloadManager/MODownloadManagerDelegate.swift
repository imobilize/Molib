import Foundation

protocol MODownloadManagerDelegate {
    
    func downloadRequestDidUpdateProgress()
    
    func downloadRequestStarted(downloadModel: MODownloadModel, index: Int)
    
    func downloadRequestPaused(downloadModel: MODownloadModel, index: Int)
    
    func downloadRequestedResumed()
    
    func downloadRequesteRetry()
    
    func downloadRequestCancelled()
    
    func downloadRequestFinished()
    
    func downloadRequestFailed()
    
}

protocol DownloadManager {
    
    func startDownload(asset: Asset)
    
    func pauseDownload(asset: Asset)
    
    func cancelDownlaod(asset: Asset)
    
    func deleteDownload(asset: Asset)
    
    func resumeDownload(asset: Asset)
    
}

protocol Asset {
    
    var id: String { get }
    
    var fileName: String { get }
    
    var fileURL: String { get }
    
}