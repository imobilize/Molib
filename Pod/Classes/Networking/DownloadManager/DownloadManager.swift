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

            let downloadTask = DataDownloadTask(downloadModel: downloadModel, downloadFileDestinationComplertionHandler: downloadFileDestinationComplertionHandler, downloadProgressCompletion: downloadProgressCompletionHandler, downloadCompletion: downloadCompletionHandler)
            
            if let downloadOperation = networkService.enqueueNetworkDownloadRequest(downloadTask) {
            
                downloadQueue.append(downloadOperation)
                
                delegate?.downloadRequestStarted?(downloadModel, index: downloadQueue.count - 1)

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
    
    private func downloadCompletionHandler(errorCompletion: NSError?) {
        
        delegate?.downloadRequestFinished?(errorCompletion)
        
    }
    
    private func downloadProgressCompletionHandler(bytesRead: Int64, totalBytesRead: Int64, totalBytesExpectedToRead: Int64) {

        delegate?.downloadRequestDidUpdateProgress?(bytesRead, totalBytesRead: totalBytesRead, totalBytesExpectedToRead: totalBytesExpectedToRead)
        
    }
    
    private func downloadFileDestinationComplertionHandler(donwloadFileTemporaryLocation: NSURL) -> NSURL {
        
        var fileUrl: NSURL!
        
        if let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as? NSURL {
            
            fileUrl = directoryURL.URLByAppendingPathComponent(downloadQueue[0].downloadModel.fileName)
            
            removeOldFileAtLocationIfExists(fileUrl)
            
        } else {
            
            fileUrl = donwloadFileTemporaryLocation
            
        }
        
        return fileUrl
        
    }
    
    private func removeOldFileAtLocationIfExists(locationToCheck: NSURL) {
        
        do {
         
            try NSFileManager.defaultManager().removeItemAtURL(locationToCheck)
            
        } catch let error as NSError {
            
            
        }
        
    }
    
}
