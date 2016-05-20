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

            let downloadTask = DataDownloadTask(downloadModel: downloadModel, downloadFileDestinationComplertionHandler: downloadFileDestinationComplertionHandler, downloadProgressCompletion: downloadProgressCompletionHandler, downloadCompletion: downloadCompletionHandler)
            
            if let downloadOperation = networkService.enqueueNetworkDownloadRequest(downloadTask) {
            
                downloadQueue.append(downloadOperation)
                
                delegate?.downloadRequestStarted(downloadOperation, index: downloadQueue.count - 1)

            }
            
        }
        
    }
    
    public func pauseDownload(asset: Asset) {
        
     
    }
    
    public func cancelDownlaod(asset: Asset) {
        
        if let operation = findDownloadOperationForAsset(asset) {
            
            operation.cancel()
            
        }
        
    }
    
    public func deleteDownload(asset: Asset) {
        
    }
    
    public func resumeDownload(asset: Asset) {
        
    }
    
    //MARK: Completions
    
    private func downloadCompletionHandler(downloadModel: MODownloadModel, errorCompletion: NSError?) {
        
        if let error = errorCompletion {
        
            downloadModel.status = DownloadTaskStatus.Failed.rawValue
            
            delegate?.downloadRequestFinished(downloadModel, errorOptional: error)
            
        } else {
         
            downloadModel.status = DownloadTaskStatus.Finished.rawValue
            
            delegate?.downloadRequestFinished(downloadModel, errorOptional: errorCompletion)
            
        }
        
    }
    
    private func downloadProgressCompletionHandler(downloadModel: MODownloadModel) {

        delegate?.downloadRequestDidUpdateProgress(downloadModel, index: downloadQueue.count - 1)
        
    }
    
    private func downloadFileDestinationComplertionHandler(donwloadFileTemporaryLocation: NSURL) -> NSURL {
        
        var fileUrl: NSURL!
        
        if let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as? NSURL {
            
            fileUrl = directoryURL.URLByAppendingPathComponent(downloadQueue[0].downloadModel.fileName)
            
            removeOldFileAtLocationIfExists(fileUrl)
            
        } else {
            
            fileUrl = donwloadFileTemporaryLocation
            
        }

        
        fileUrl = donwloadFileTemporaryLocation
        
        return fileUrl
        
    }
    
    //MARK: Helpers
    
    private func removeOldFileAtLocationIfExists(locationToCheck: NSURL) {
        
        do {
         
            try NSFileManager.defaultManager().removeItemAtURL(locationToCheck)
            
        } catch let error as NSError {
            
            
        }
        
    }
    
    private func findDownloadOperationForAsset(asset: Asset) -> DownloadOperation? {
        
        return downloadQueue.filter { $0.downloadModel.fileName == asset.fileName && $0.downloadModel.fileURL == asset.fileURL }.first

    }
    
}
