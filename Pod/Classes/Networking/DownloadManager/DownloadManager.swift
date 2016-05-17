import Foundation

public class MODownloadManager: DownloadManager {
    
    public let delegate: MODownloadManagerDelegate?
    public let networkService: NetworkService!
    
    public var downloadQueue: [MODownloadModel] = []
    
    public init(networkService: NetworkService, delegate: MODownloadManagerDelegate) {
        
        self.networkService = networkService
        
        self.delegate = delegate
        
    }
    
    func pauseDownloadTaskAtIndex(index: Int) {
        
        
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
        
    }
    
    public func deleteDownload(asset: Asset) {
        
    }
    
    public func resumeDownload(asset: Asset) {
        
    }
    
    private func downloadCompletionHandler(errorCompletion: NSError?) {
        
        delegate?.downloadRequestFinished(errorCompletion)
        
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
    
    private func downloadProgressCompletionHandler(bytesRead: Int64, totalBytesRead: Int64, totalBytesExpectedToRead: Int64) {
        
        delegate?.downloadRequestDidUpdateProgress(bytesRead, totalBytesRead: totalBytesRead, totalBytesExpectedToRead: totalBytesExpectedToRead)
        
    }
    
}
