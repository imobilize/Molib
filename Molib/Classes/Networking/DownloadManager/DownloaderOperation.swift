import Foundation

protocol DownloaderOperationDelegate {
    func downloaderOperationDidUpdateProgress(progress: Float, forTask: DownloaderTask)
    func downloaderOperationDidStartDownload(forTask: DownloaderTask)
    func downloaderOperationDidFailDownload(withError: Error, forTask: DownloaderTask)
    func downloaderOperationDidComplete(forTask: DownloaderTask)
}


class DownloaderOperation: Operation {

    var delegate: DownloaderOperationDelegate?
    private let downloaderTask: DownloaderTask
    private let networkOperationService: NetworkRequestService
    private var networkDownloadOperation: NetworkDownloadOperation?

    init(downloaderTask: DownloaderTask, networkOperationService: NetworkRequestService) {
        self.downloaderTask = downloaderTask
        self.networkOperationService = networkOperationService
    }

    override func main() {

        delegate?.downloaderOperationDidStartDownload(forTask: downloaderTask)

        let semaphore = DispatchSemaphore(value: 0)

        let downloadRequest = DataDownloadTask(downloaderTask: downloaderTask) { [weak self](_, errorOptional) in

            semaphore.signal()

            if let strongSelf = self {

                if let error = errorOptional {

                    strongSelf.delegate?.downloaderOperationDidFailDownload(withError: error, forTask: strongSelf.downloaderTask)

                } else {

                    strongSelf.delegate?.downloaderOperationDidComplete(forTask: strongSelf.downloaderTask)
                }
            }
        }

        networkDownloadOperation = networkOperationService.enqueueNetworkDownloadRequest(request: downloadRequest)
        networkDownloadOperation?.registerProgressUpdate(progressUpdate: handleProgressUpdate)

        semaphore.wait()
    }

    override func cancel() {
        networkDownloadOperation?.cancel()
    }

    func pause() {
        networkDownloadOperation?.pause()
    }

    func resume() {
        networkDownloadOperation?.resume()
    }

    func handleProgressUpdate(progress: Float) {
        delegate?.downloaderOperationDidUpdateProgress(progress: progress, forTask: downloaderTask)
    }

    func matchesDownloaderTask(task: DownloaderTask)  -> Bool {
        return downloaderTask == task
    }

    override func isEqual(_ object: Any?) -> Bool {

        if let operation = object as? DownloaderOperation {
            return operation.downloaderTask.downloadURL == self.downloaderTask.downloadURL
        }

        return false
    }
}

extension DataDownloadTask {
    init(downloaderTask: DownloaderTask, taskCompletion: @escaping DataResponseCompletion) {
        self.fileName = downloaderTask.fileName
        self.downloadLocationURL = downloaderTask.downloadDestinationURL
        self.urlRequest = URLRequest(url: downloaderTask.downloadURL)
        self.taskCompletion = taskCompletion
    }
}
