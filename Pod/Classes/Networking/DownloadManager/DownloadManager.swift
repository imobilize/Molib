import Foundation


let MODownloadManagerImplDomain = "DownloadManager"

enum MODownloadManagerErrorCode: Int {
    
    case InvalidURL = 301;
}


public class DownloadManagerFactory {
    
    public class func downloadManager() -> DownloadManager {
        
        let downloader = DownloaderImpl(session:  MODownloadManagerImplDomain)
        
        let downloadManager = MODownloadManagerImpl(downloader: downloader)
        
        return downloadManager
    }
}


public class MODownloadManagerImpl: DownloadManager {
    
    let downloader: Downloader
    
    var downloadQueue: [String: (Downloadable, Int)] = [:]
    
    public var delegate: MODownloadManagerDelegate?
    
    
    public init(downloader: Downloader) {
        
        self.downloader = downloader
        self.downloader.delegate = self
    }
    
    //MARK: DownloadManager Protocol
    
    public func startDownload(downloadable: Downloadable) {
        
        if let fileName = downloadable.fileName, fileURL = downloadable.fileURL {
            
            self.downloader.addDownloadTask(downloadable.id, fileName: fileName, fileURL: fileURL)
            
        } else {
            
            let error = NSError(domain: MODownloadManagerImplDomain, code: MODownloadManagerErrorCode.InvalidURL.rawValue, userInfo: nil)
            
            self.delegate?.downloadRequestFailed(downloadable, error: error)
        }
        
    }
    
    public func pauseDownload(downloadable: Downloadable) {
        
        if let (_, index) = downloadQueue[downloadable.fileURL] {
            
             downloader.pauseDownloadTaskAtIndex(index)
        }
    }
    
    public func cancelDownload(downloadable: Downloadable) {
        
        if let (_, index) = downloadQueue[downloadable.fileURL] {
            
            downloader.cancelTaskAtIndex(index)
        }
        
    }
    
    
    public func resumeDownload(downloadable: Downloadable) {
        
        if let (_, index) = downloadQueue[downloadable.fileURL] {
            
            downloader.resumeDownloadTaskAtIndex(index)
        } else {
            
            startDownload(downloadable)
        }
    }
    
}

extension MODownloadManagerImpl: DownloaderDelegate {
    
    public func downloadRequestDidUpdateProgress(downloadModel: DownloadModel, index: Int) {
        
        self.delegate?.downloadDidUpdateProgress(downloadModel, progress: downloadModel.progress)
    }
    
    /**A delegate method called when interrupted tasks are repopulated
     */
    public func downloadRequestDidPopulatedInterruptedTasks(downloadModel: [DownloadModel]) {
        
    }
    
    /**A delegate method called each time whenever new download task is start downloading
     */
    public func downloadRequestStarted(downloadModel: DownloadModel, index: Int) {
        
        self.downloadQueue[downloadModel.fileURL] = (downloadModel, index)
        self.delegate?.downloadRequestStarted(downloadModel)
    }
    
    /**A delegate method called each time whenever running download task is paused. If task is already paused the action will be ignored
     */
    public func downloadRequestDidPaused(downloadModel: DownloadModel, index: Int) {
        
        self.delegate?.downloadRequestPaused(downloadModel)
    }
    
    /**A delegate method called each time whenever any download task is resumed. If task is already downloading the action will be ignored
     */
    public func downloadRequestDidResumed(downloadModel: DownloadModel, index: Int) {
        
        self.delegate?.downloadRequestedResumed(downloadModel)
    }
    
    /**A delegate method called each time whenever any download task is resumed. If task is already downloading the action will be ignored
     */
    public func downloadRequestDidRetry(downloadModel: DownloadModel, index: Int) {
        
        self.delegate?.downloadRequestStarted(downloadModel)
    }
    
    /**A delegate method called each time whenever any download task is cancelled by the user
     */
    public func downloadRequestCanceled(downloadModel: DownloadModel, index: Int) {
        
        self.delegate?.downloadRequestCancelled(downloadModel)
    }
    
    /**A delegate method called each time whenever any download task is finished successfully
     */
    public func downloadRequestFinished(downloadModel: DownloadModel, index: Int) {
        
        self.downloadQueue.removeValueForKey(downloadModel.fileURL)
        
        self.delegate?.downloadRequestFinished(downloadModel)
    }
    
    /**A delegate method called each time whenever any download task is failed due to any reason
     */
    public func downloadRequestDidFailedWithError(error: NSError, downloadModel: DownloadModel, index: Int) {
        
        self.delegate?.downloadRequestFailed(downloadModel, error: error)
    }

}