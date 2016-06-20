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
        
        if let fileName = downloadable.fileURL, fileURL = downloadable.fileURL {
            
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
        }
    }
//    
//    //MARK: Completions
//    
//    private func downloadCompletionHandler(downloadModel: MODownloadModel, errorCompletion: NSError?) {
//        
//        if let error = errorCompletion {
//        
////            downloadModel.status = DownloadTaskStatus.Failed.rawValue
////            
////            delegate?.downloadRequestFailed(downloadModel, errorOptional: error)
//            
//        } else {
//         
////            downloadModel.status = DownloadTaskStatus.Finished.rawValue
////            
////            delegate?.downloadRequestFinished(downloadModel, errorOptional: errorCompletion)
//            
//        }
//        
//    }
//    
//    private func provideDownloadLocation(downloadModel: MODownloadModel, donwloadFileTemporaryLocation: NSURL) -> NSURL {
//        
//        var fileUrl: NSURL!
//        
//        if let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as? NSURL {
//            
////            fileUrl = directoryURL.URLByAppendingPathComponent(downloadModel.fileName)
//            
//            removeOldFileAtLocationIfExists(fileUrl)
//            
//        } else {
//            
//            fileUrl = donwloadFileTemporaryLocation
//            
//        }
//
//        return fileUrl
//        
//    }
//    
//    //MARK: Helpers
//    
//    private func provideDownloadModelAttributes(downloadable: Downloadable) -> StorableDictionary {
//        
//        var downloadAttributeDictionary: StorableDictionary = [:]
//        
//        downloadAttributeDictionary[DownloadModelAttributes.id.rawValue] = downloadable.id
//        
//        downloadAttributeDictionary[DownloadModelAttributes.fileName.rawValue] = downloadable.fileName
//        
//        downloadAttributeDictionary[DownloadModelAttributes.fileURL.rawValue] = downloadable.fileURL
//        
//        return downloadAttributeDictionary
//    }
//    
//    private func removeOldFileAtLocationIfExists(locationToCheck: NSURL) {
//        
//        do {
//         
//            try NSFileManager.defaultManager().removeItemAtURL(locationToCheck)
//            
//        } catch let error as NSError {
//            
//            
//        }
//        
//    }
//    
//    private func findDownloadOperationAndIndexForDownloadable(downloadable: Downloadable) -> (operation: DownloadOperation, index: Int)? {
//        
//        var operationIndex: (DownloadOperation, Int)?
//        
////        if let index = downloadQueue.indexOf ({ $0.downloadModel.downloadable?.id == downloadable.id }) {
////         
////            let downloadOperation = downloadQueue[index]
////            
////            operationIndex = (downloadOperation, index)
////            
////        }
//        
//        return operationIndex
//
//    }
    
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
        
        self.delegate?.downloadRequestFinished(downloadModel)
    }
    
    /**A delegate method called each time whenever any download task is failed due to any reason
     */
    public func downloadRequestDidFailedWithError(error: NSError, downloadModel: DownloadModel, index: Int) {
        
        self.delegate?.downloadRequestFailed(downloadModel, error: error)
    }

}