import Foundation

public protocol MODownloadManagerDelegate {
        
    func downloadRequestStarted(downloadable: Downloadable)
    
    func downloadRequestPaused(downloadable: Downloadable)
    
    func downloadRequestedResumed(downloadable: Downloadable)
    
    func downloadRequesteDeleted(downloadable: Downloadable)
    
    func downloadRequestCancelled(downloadable: Downloadable)
    
    func downloadRequestFinished(downloadable: Downloadable)
    
    func downloadRequestFailed(downloadable: Downloadable, error: NSError)
    
    /* This should really return a model that has speed, remaining time, total bytes etc Just doing the simplest thing for now */
    func downloadDidUpdateProgress(downloadable: Downloadable, progress: Float)
}

public protocol DownloadManager {
    
    var delegate: MODownloadManagerDelegate? { get set }
    
    func startDownload(downloadable: Downloadable)
    
    func pauseDownload(downloadable: Downloadable)
    
    func cancelDownload(downloadable: Downloadable)
        
    func resumeDownload(downloadable: Downloadable)
    
}
