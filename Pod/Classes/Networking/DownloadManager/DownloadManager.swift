import Foundation

public class MODownloadManager: DownloadManager {
    
    public let networkService: NetworkService!
    
    public var downloadQueue: [DownloadOperation] = []
    
    public var delegate: MODownloadManagerDelegate?
    
    public init(networkService: NetworkService) {
        
        self.networkService = networkService

    }
    
    //MARK: DownloadManager Protocol
    
    public func startDownload(asset: Asset) {
        
        if let request = NSURLRequest.GETRequest(asset.fileURL) {
            
            let downloadModel = MODownloadModel(fileName: asset.fileName, fileURL: asset.fileURL)
            
            downloadModel.startTime = NSDate()
            
            downloadModel.status = DownloadTaskStatus.Downloading.rawValue
            
            downloadModel.request = request
            
            downloadModel.asset = asset

            let downloadTask = DataDownloadTask(downloadModel: downloadModel, downloadLocation: provideDownloadLocation, downloadProgressCompletion: downloadProgressCompletion, downloadCompletion: downloadCompletionHandler)
            
            downloadModel.downloadTask = downloadTask
            
            if let downloadOperation = networkService.enqueueNetworkDownloadRequest(downloadTask) {
            
                downloadQueue.append(downloadOperation)
                
                delegate?.downloadRequestStarted(downloadOperation, index: downloadQueue.count - 1)

            }
            
        }
        
    }
    
    public func pauseDownload(asset: Asset) {
        
        if let (operation, index) = findDownloadOperationAndIndexForAsset(asset) {
            
            operation.pause()
            
            operation.downloadModel.status = DownloadTaskStatus.Paused.rawValue
            
            delegate?.downloadRequestPaused(operation.downloadModel, index: index)
            
        }
     
    }
    
    public func cancelDownload(asset: Asset) {
        
        if let (operation, index) = findDownloadOperationAndIndexForAsset(asset) {
            
            operation.cancel()
            
            operation.downloadModel.status = DownloadTaskStatus.Failed.rawValue
            
            delegate?.downloadRequestCancelled(operation.downloadModel, index: index)
            
        }
        
    }
    
    public func deleteDownload(asset: Asset) {
        
        if let (operation, index) = findDownloadOperationAndIndexForAsset(asset) {

            operation.cancel()
            
            downloadQueue.removeAtIndex(index)
            
            delegate?.downloadRequesteDeleted(operation.downloadModel, index: index)
            
        }
        
    }
    
    public func resumeDownload(asset: Asset) {
        
        if let (operation, index) = findDownloadOperationAndIndexForAsset(asset) {
            
            operation.resume()
            
            operation.downloadModel.status = DownloadTaskStatus.Downloading.rawValue
            
            delegate?.downloadRequestedResumed(operation.downloadModel, index: index)
            
        }

    }
    
    //MARK: Completions
    
    private func downloadCompletionHandler(downloadModel: MODownloadModel, errorCompletion: NSError?) {
        
        if let error = errorCompletion {
        
            downloadModel.status = DownloadTaskStatus.Failed.rawValue
            
            delegate?.downloadRequestFailed(downloadModel, errorOptional: error)
            
        } else {
         
            downloadModel.status = DownloadTaskStatus.Finished.rawValue
            
            delegate?.downloadRequestFinished(downloadModel, errorOptional: errorCompletion)
            
        }
        
    }
    
    private func downloadProgressCompletion(downloadModel: MODownloadModel) {

        delegate?.downloadRequestDidUpdateProgress(downloadModel, index: downloadQueue.count - 1)
        
    }
    
    private func provideDownloadLocation(downloadModel: MODownloadModel, donwloadFileTemporaryLocation: NSURL) -> NSURL {
        
        var fileUrl: NSURL!
        
        if let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as? NSURL {
            
            fileUrl = directoryURL.URLByAppendingPathComponent(downloadModel.fileName)
            
            removeOldFileAtLocationIfExists(fileUrl)
            
        } else {
            
            fileUrl = donwloadFileTemporaryLocation
            
        }

        return fileUrl
        
    }
    
    //MARK: Helpers
    
    private func removeOldFileAtLocationIfExists(locationToCheck: NSURL) {
        
        do {
         
            try NSFileManager.defaultManager().removeItemAtURL(locationToCheck)
            
        } catch let error as NSError {
            
            
        }
        
    }
    
    private func findDownloadOperationAndIndexForAsset(asset: Asset) -> (operation: DownloadOperation, index: Int)? {
        
        var operationIndex: (DownloadOperation, Int)?
        
        if let index = downloadQueue.indexOf ({ $0.downloadModel.asset?.id == asset.id }) {
         
            let downloadOperation = downloadQueue[index]
            
            operationIndex = (downloadOperation, index)
            
        }
        
        return operationIndex

    }
    
}
