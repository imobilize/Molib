import Foundation

public protocol MODownloadManagerDelegate {
        
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
    
    var downloadQueue: [DownloadOperation] { get }
    
    func startDownload(downloadable: Downloadable)
    
    func pauseDownload(downloadable: Downloadable)
    
    func cancelDownload(downloadable: Downloadable)
    
    func deleteDownload(downloadable: Downloadable)
    
    func resumeDownload(downloadable: Downloadable)
    
    func getDownloadModelForDownloadable(downloadable: Downloadable) -> MODownloadModel?
    
}
