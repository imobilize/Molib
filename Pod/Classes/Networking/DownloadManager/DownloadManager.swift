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
            
            let downloadTask = DataDownloadTask(urlRequest: request, downloadFileName: asset.fileName, downloadFileDestinationComplertionHandler: downloadFileDestinationComplertionHandler, downloadCompletion: downloadCompletionHandler)
            
            let downloadModel = MODownloadModel(fileName: asset.fileName, fileURL: asset.fileURL)
            
            downloadModel.downloadTask = downloadTask
            
            downloadModel.operation = networkService.enqueueNetworkDownloadRequest(downloadTask)
            
            downloadModel.status = DownloadTaskStatus.Downloading.rawValue
            
            downloadQueue.append(downloadModel)

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
    
    private func downloadFileDestinationComplertionHandler(downloadLocation: NSURL) {
        
        //Take the file location and save it to the asset / downloadModel
        
    }
    
}
