import Foundation

public protocol MODownloadManagerDelegate {
    
    func downloadRequestDidUpdateProgress(downloadModel: MODownloadModel, index: Int)
    
    func downloadRequestStarted(downloadOperation: DownloadOperation, index: Int)
    
    func downloadRequestPaused(downloadModel: MODownloadModel, index: Int)
    
    func downloadRequestedResumed(downloadModel: MODownloadModel, index: Int)
    
    func downloadRequesteDeleted(downloadModel: MODownloadModel, index: Int)
    
    func downloadRequestCancelled(downloadModel: MODownloadModel, index: Int)
    
    func downloadRequestFinished(downloadModel: MODownloadModel, errorOptional: NSError?)
    
    func downloadRequestFailed(downloadModel: MODownloadModel, errorOptional: NSError?)
    
}

public protocol DownloadManager {
    
    var delegate: MODownloadManagerDelegate? { get set }
    
    func startDownload(asset: Asset)
    
    func pauseDownload(asset: Asset)
    
    func cancelDownload(asset: Asset)
    
    func deleteDownload(asset: Asset)
    
    func resumeDownload(asset: Asset)
    
}

public protocol Asset {
    
    var id: String { get }
    
    var fileName: String { get }
    
    var fileURL: String { get }
    
}