import Foundation


public protocol NetworkDownloaderDelegate {
    /**A delegate method called each time whenever any download task's progress is updated
     */
    func downloadRequestDidUpdateProgress(downloadModel: DownloadModel, index: Int)
    /**A delegate method called when interrupted tasks are repopulated
     */
    func downloadRequestDidPopulatedInterruptedTasks(downloadModel: [DownloadModel])
    /**A delegate method called each time whenever new download task is start downloading
     */
    func downloadRequestStarted(downloadModel: DownloadModel, index: Int)
    /**A delegate method called each time whenever running download task is paused. If task is already paused the action will be ignored
     */
    func downloadRequestDidPaused(downloadModel: DownloadModel, index: Int)
    /**A delegate method called each time whenever any download task is resumed. If task is already downloading the action will be ignored
     */
    func downloadRequestDidResumed(downloadModel: DownloadModel, index: Int)
    /**A delegate method called each time whenever any download task is resumed. If task is already downloading the action will be ignored
     */
    func downloadRequestDidRetry(downloadModel: DownloadModel, index: Int)
    /**A delegate method called each time whenever any download task is cancelled by the user
     */
    func downloadRequestCanceled(downloadModel: DownloadModel, index: Int)
    /**A delegate method called each time whenever any download task is finished successfully
     */
    func downloadRequestFinished(downloadModel: DownloadModel, index: Int)
    /**A delegate method called each time whenever any download task is failed due to any reason
     */
    func downloadRequestDidFailedWithError(error: NSError, downloadModel: DownloadModel, index: Int)

}


class NetworkDownloader: Downloader {

    private let inProgressOperationQueue = OperationQueue()
    private var pausedOperationQueue = [DownloaderOperation]()
    private let networkOperationService: NetworkOperationService
    var delegate: DownloaderDelegate?

    init(networkOperationService: NetworkOperationService) {
        self.networkOperationService = networkOperationService
    }

    func addDownloadTask(task: DownloaderTask) {
        let downloadOperation = DownloaderOperation(downloaderTask: task, networkOperationService: networkOperationService)
        guard inProgressOperationQueue.operations.contains(downloadOperation) == false else {
            return
        }
        downloadOperation.delegate = self
        inProgressOperationQueue.addOperation(downloadOperation)
    }

    func pauseDownloadTask(task: DownloaderTask) {

        if let operation = operationForTask(task: task) {
            operation.pause()
            pausedOperationQueue.append(operation)
        }
    }

    func resumeDownloadTask(task: DownloaderTask) {
        if let operation = pausedOperationQueue.first(where: { (operationInQueue) -> Bool in
            operationInQueue.matchesDownloaderTask(task: task)
        }) {
            
            inProgressOperationQueue.addOperation(operation)
        }
    }

    func retryDownloadTask(task: DownloaderTask) {
        addDownloadTask(task: task)
    }

    func cancelTask(task: DownloaderTask) {
        let operation = operationForTask(task: task)
        operation?.cancel()
    }

    private func operationForTask(task: DownloaderTask) -> DownloaderOperation? {
        let operationsForTask = inProgressOperationQueue.operations.filter { (operationInQueue) in
            var matches = false
            if let operation = operationInQueue as? DownloaderOperation {
                matches = operation.matchesDownloaderTask(task: task)
            }
            return matches
        }
        return operationsForTask.first as? DownloaderOperation
    }
}

extension NetworkDownloader: DownloaderOperationDelegate {

    func downloaderOperationDidUpdateProgress(progress: Float, forTask: DownloaderTask) {
        
    }

    func downloaderOperationDidStartDownload(forTask: DownloaderTask) {

    }

    func downloaderOperationDidFailDownload(withError: Error, forTask: DownloaderTask) {

    }

    func downloaderOperationDidComplete(forTask: DownloaderTask) {

    }
}

