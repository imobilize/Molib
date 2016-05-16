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
        
        let downloadModel = downloadQueue[index]
        
        guard downloadModel.status != DownloadTaskStatus.Paused.rawValue else {
            
            return
            
        }
        
        if let downloadTask = downloadModel.request {
            
            downloadModel.status = DownloadTaskStatus.Paused.rawValue
            
            downloadModel.startTime = NSDate()
            
            downloadQueue[index] = downloadModel
            
            delegate?.downloadRequestPaused(downloadModel, index: index)
            
        }
        
    }
    
    public func startDownload(asset: Asset) {
        
        if let request = NSURLRequest.GETRequest(asset.fileURL) {
       
            let downloadModel = MODownloadModel(fileName: asset.fileName, fileURL: asset.fileURL)
            
            downloadModel.request = DataDownloadTask(urlRequest: request)
            
            downloadModel.status = DownloadTaskStatus.Downloading.rawValue
            
            downloadQueue.append(downloadModel)
            
            networkService.enqueueNetworkDownloadRequest(downloadModel)
            
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
    
}
