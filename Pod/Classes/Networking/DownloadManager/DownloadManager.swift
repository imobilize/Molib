import Foundation

public class MODownloadManager: DownloadManager {
    
    public let networkService: NetworkService!
    
    public var downloadQueue: [DownloadOperation] = []
    
    public var delegate: MODownloadManagerDelegate?
    
    public init(networkService: NetworkService) {
        
        self.networkService = networkService

    }
    
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
        
    }
    
    public func deleteDownload(asset: Asset) {
        
    }
    
    public func resumeDownload(asset: Asset) {
        
    }
    
    private func downloadCompletionHandler(downloadModel: MODownloadModel, errorCompletion: NSError?) {
        
        downloadModel.status = DownloadTaskStatus.Finished.rawValue
        
        delegate?.downloadRequestFinished(downloadModel, errorOptional: errorCompletion)
        
    }
    
    private func downloadProgressCompletionHandler(downloadModel: MODownloadModel) {

        delegate?.downloadRequestDidUpdateProgress(downloadModel, index: downloadQueue.count - 1)
        
    }
    
    private func downloadFileDestinationComplertionHandler(donwloadFileTemporaryLocation: NSURL) -> NSURL {
        
        var fileUrl: NSURL!
        
        if let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as? NSURL {
            
//            fileUrl = directoryURL.URLByAppendingPathComponent(downloadQueue[0].downloadModel.fileName)
            
//            removeOldFileAtLocationIfExists(fileUrl)
            
        } else {
            
            fileUrl = donwloadFileTemporaryLocation
            
        }

        
        fileUrl = donwloadFileTemporaryLocation
        
        return fileUrl
        
    }
    
    private func removeOldFileAtLocationIfExists(locationToCheck: NSURL) {
        
        do {
         
            try NSFileManager.defaultManager().removeItemAtURL(locationToCheck)
            
        } catch let error as NSError {
            
            
        }
        
    }
    
}
