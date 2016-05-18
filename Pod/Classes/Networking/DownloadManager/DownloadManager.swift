import Foundation

public class MODownloadManager: DownloadManager {
    
    public let networkService: NetworkService!
    
    public var downloadQueue: [MODownloadModel] = []
    
    public var delegate: MODownloadManagerDelegate?
    
    public init(networkService: NetworkService) {
        
        self.networkService = networkService

    }
    
    public func startDownload(asset: Asset) {
        
        if let request = NSURLRequest.GETRequest(asset.fileURL) {
            
            let downloadTask = DataDownloadTask(urlRequest: request, downloadFileDestinationComplertionHandler: downloadFileDestinationComplertionHandler, downloadProgressCompletion: downloadProgressCompletionHandler, downloadCompletion: downloadCompletionHandler)
            
            let downloadModel = MODownloadModel(fileName: asset.fileName, fileURL: asset.fileURL)
            
            downloadModel.downloadTask = downloadTask
            
            downloadModel.status = DownloadTaskStatus.Downloading.rawValue

            downloadQueue.append(downloadModel)

            downloadModel.operation = networkService.enqueueNetworkDownloadRequest(downloadTask)

            delegate?.downloadRequestStarted(downloadModel, index: downloadQueue.count - 1)
            
        }
        
    }
    
    public func pauseDownload(asset: Asset) {
     
    }
    
    public func cancelDownlaod(asset: Asset) {
     
        let cancelOperation = fetchOperationForAsset(asset)
        
        cancelOperation?.cancel()
        
    }
    
    public func deleteDownload(asset: Asset) {
        
    }
    
    public func resumeDownload(asset: Asset) {
        
    }
    
    private func fetchOperationForAsset(asset: Asset) -> Operation? {
        
        let downloadQueueModelForAsset = downloadQueue.filter { $0.fileName == asset.fileName }.first
        
        let operationForAsset = downloadQueueModelForAsset?.operation
        
        return operationForAsset
        
    }
    
    private func downloadCompletionHandler(errorCompletion: NSError?) {
        
        delegate?.downloadRequestFinished(errorCompletion)
        
    }
    
    private func downloadProgressCompletionHandler(bytesRead: Int64, totalBytesRead: Int64, totalBytesExpectedToRead: Int64) {
        
        delegate?.downloadRequestDidUpdateProgress(bytesRead, totalBytesRead: totalBytesRead, totalBytesExpectedToRead: totalBytesExpectedToRead)
        
    }
    
    private func downloadFileDestinationComplertionHandler(donwloadFileTemporaryLocation: NSURL) -> NSURL {
        
        var fileUrl: NSURL!
        
        if let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as? NSURL {
            
            fileUrl = directoryURL.URLByAppendingPathComponent(downloadQueue[0].fileName)
            
        } else {
            
            fileUrl = donwloadFileTemporaryLocation
            
        }
        
        return fileUrl
        
    }
    
}
