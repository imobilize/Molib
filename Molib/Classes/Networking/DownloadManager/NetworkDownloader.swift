import Foundation


class NetworkDownloader: Downloader {

    private let inProgressOperationQueue = OperationQueue()
    private var pausedOperationQueue = [DownloaderOperation]()
    private let networkOperationService: NetworkRequestService
    var delegate: DownloaderDelegate?

    init(networkOperationService: NetworkRequestService) {
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

