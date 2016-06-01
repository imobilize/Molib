import Foundation

public class MODownloadManager: DownloadManager {
    
    public let networkService: NetworkService!
    
    public let dataStore: DataStore!
    
    public var downloadQueue: [String: (MODownloadModel, Operation?)] = [:]
    
    public var delegate: MODownloadManagerDelegate?
    
    public init(networkService: NetworkService, dataStore: DataStore) {
        
        self.networkService = networkService
        
        self.dataStore = dataStore

    }
    
    //MARK: DownloadManager Protocol
    
    public func startDownload(downloadable: Downloadable) {
        
        if let request = NSURLRequest.GETRequest(downloadable.fileURL!) {
            
            let downloadTask = DataDownloadTask(urlRequest: request, downloadProgress: downloadProgressCompletion, downloadLocation: provideDownloadLocation, downloadCompletion: downloadCompletionHandler)
            
            let downloadOperation = networkService.enqueueNetworkDownloadRequest(downloadTask)
            
            let downloadModelAttributes = provideDownloadModelAttributes(downloadable)

<<<<<<< Updated upstream
            let downloadTask = DataDownloadTask(downloadModel: downloadModel, downloadLocation: provideDownloadLocation, downloadCompletion: downloadCompletionHandler)
=======
            let downloadModel = MODownloadModel(dictionary: downloadModelAttributes)
>>>>>>> Stashed changes
            
            downloadQueue.updateValue((downloadModel, downloadOperation), forKey: downloadable.id!)
            
        }
        
    }
    
    public func pauseDownload(downloadable: Downloadable) {
        
        if let (operation, index) = findDownloadOperationAndIndexForDownloadable(downloadable) {
            
//            operation.pause()
//            
//            operation.downloadModel.status = DownloadTaskStatus.Paused.rawValue
//            
//            delegate?.downloadRequestPaused(operation.downloadModel, index: index)
            
        }
     
    }
    
    public func cancelDownload(downloadable: Downloadable) {
        
        if let (operation, index) = findDownloadOperationAndIndexForDownloadable(downloadable) {
            
//            operation.cancel()
//            
//            operation.downloadModel.status = DownloadTaskStatus.Failed.rawValue
//            
//            delegate?.downloadRequestCancelled(operation.downloadModel, index: index)

        }
        
    }
    
    public func deleteDownload(downloadable: Downloadable) {
        
        if let (operation, index) = findDownloadOperationAndIndexForDownloadable(downloadable) {

//            operation.cancel()
//            
//            downloadQueue.removeAtIndex(index)
//            
//            delegate?.downloadRequesteDeleted(operation.downloadModel, index: index)
            
        }
        
    }
    
    public func resumeDownload(downloadable: Downloadable) {
        
        if let (operation, index) = findDownloadOperationAndIndexForDownloadable(downloadable) {
            
//            operation.resume()
//            
//            operation.downloadModel.status = DownloadTaskStatus.Downloading.rawValue
//            
//            delegate?.downloadRequestedResumed(operation.downloadModel, index: index)

        }

    }
    
    public func getDownloadModelForDownloadable(downloadable: Downloadable) -> MODownloadModel? {
        
        var downloadModel: MODownloadModel?
        
        if let (operation, index) = findDownloadOperationAndIndexForDownloadable(downloadable) {
            
//            downloadModel = operation.downloadModel
            
        }
        
        return downloadModel
        
    }
    
    //MARK: Completions
    
    private func downloadCompletionHandler(downloadModel: MODownloadModel, errorCompletion: NSError?) {
        
        if let error = errorCompletion {
        
//            downloadModel.status = DownloadTaskStatus.Failed.rawValue
//            
//            delegate?.downloadRequestFailed(downloadModel, errorOptional: error)
            
        } else {
         
//            downloadModel.status = DownloadTaskStatus.Finished.rawValue
//            
//            delegate?.downloadRequestFinished(downloadModel, errorOptional: errorCompletion)
            
        }
        
    }
    
    private func provideDownloadLocation(downloadModel: MODownloadModel, donwloadFileTemporaryLocation: NSURL) -> NSURL {
        
        var fileUrl: NSURL!
        
        if let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as? NSURL {
            
//            fileUrl = directoryURL.URLByAppendingPathComponent(downloadModel.fileName)
            
            removeOldFileAtLocationIfExists(fileUrl)
            
        } else {
            
            fileUrl = donwloadFileTemporaryLocation
            
        }

        return fileUrl
        
    }
    
    //MARK: Helpers
    
    private func provideDownloadModelAttributes(downloadable: Downloadable) -> StorableDictionary {
        
        var downloadAttributeDictionary: StorableDictionary = [:]
        
        downloadAttributeDictionary[DownloadModelAttributes.id.rawValue] = downloadable.id
        
        downloadAttributeDictionary[DownloadModelAttributes.fileName.rawValue] = downloadable.fileName
        
        downloadAttributeDictionary[DownloadModelAttributes.fileURL.rawValue] = downloadable.fileURL
        
        return downloadAttributeDictionary
    }
    
    private func removeOldFileAtLocationIfExists(locationToCheck: NSURL) {
        
        do {
         
            try NSFileManager.defaultManager().removeItemAtURL(locationToCheck)
            
        } catch let error as NSError {
            
            
        }
        
    }
    
    private func findDownloadOperationAndIndexForDownloadable(downloadable: Downloadable) -> (operation: DownloadOperation, index: Int)? {
        
        var operationIndex: (DownloadOperation, Int)?
        
//        if let index = downloadQueue.indexOf ({ $0.downloadModel.downloadable?.id == downloadable.id }) {
//         
//            let downloadOperation = downloadQueue[index]
//            
//            operationIndex = (downloadOperation, index)
//            
//        }
        
        return operationIndex

    }
    
}
