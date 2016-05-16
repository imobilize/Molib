import Foundation

class MODownloadManager: DownloadManager {
    
    private let delegate: MODownloadManagerDelegate?
    private let networkService: NetworkService!
    
    var downloadQueue: [MODownloadModel] = []
    
    init(networkService: NetworkService, delegate: MODownloadManagerDelegate) {
        
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
    
    func startDownload(asset: Asset) {
        
        if let request = NSURLRequest.GETRequest(asset.fileURL) {
       
            let downloadModel = MODownloadModel(fileName: asset.fileName, fileURL: asset.fileURL)
            
            downloadModel.request = DataDownloadTask(urlRequest: request)
            
            downloadModel.status = DownloadTaskStatus.Downloading.rawValue
            
            downloadQueue.append(downloadModel)
            
            networkService.enqueueNetworkDownloadRequest(downloadModel)
            
            delegate?.downloadRequestStarted(downloadModel, index: downloadQueue.count - 1)
            
        }
        
    }
    
    func pauseDownload(asset: Asset) {
        
    }
    
    func cancelDownlaod(asset: Asset) {
        
    }
    
    func deleteDownload(asset: Asset) {
        
    }
    
    func resumeDownload(asset: Asset) {
        
    }
    
}
