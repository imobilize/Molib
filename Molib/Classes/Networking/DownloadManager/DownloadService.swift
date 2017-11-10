import Foundation

public protocol DownloadService {

    func enqueueDownload(downloadable: Downloadable) -> DownloadServiceOperation

    func resumeDownload(downloadable: Downloadable) -> DownloadServiceOperation

    func currentDownloadServiceOperations() -> [DownloadServiceOperation]
}

public protocol DownloadServiceOperation {

    func downloadableIdentifier() -> String

    func downloadURL() -> URL

    func pauseDownload()

    func resumeDownload()

    func cancelDownload()
}

class DownloadServiceImpl: DownloadService {

    private let downloader: Downloader
    private var currentOperations = [DownloadServiceOperation]()

    init(downloader: Downloader) {
        self.downloader = downloader
    }

    func enqueueDownload(downloadable: Downloadable) -> DownloadServiceOperation {

        let downloadOperation = createAndAppendDownloadOperation(downloadable: downloadable)

        downloadOperation.startDownload()

        return downloadOperation
    }

    func resumeDownload(downloadable: Downloadable) -> DownloadServiceOperation {

        let downloadOperation = createAndAppendDownloadOperation(downloadable: downloadable)

        downloadOperation.resumeDownload()

        return downloadOperation
    }

    func currentDownloadServiceOperations() -> [DownloadServiceOperation] {
        return currentOperations
    }

    private func createAndAppendDownloadOperation(downloadable: Downloadable) -> DownloadServiceOperationImpl {

        let downloaderTask = DownloaderTask(uniqueIdentifier: downloadable.uniqueIdentifier(), downloadURL: downloadable.url(), downloadDestinationURL: downloadable.localURL(), fileName: downloadable.downloadName())

        downloader.addDownloadTask(task: downloaderTask)

        let downloadServiceOperation = DownloadServiceOperationImpl(downloaderTask: downloaderTask, downloader: downloader)

        currentOperations.append(downloadServiceOperation)

        return downloadServiceOperation
    }
}

class DownloadServiceOperationImpl {

    private let downloaderTask: DownloaderTask
    private let downloader: Downloader

    init(downloaderTask: DownloaderTask, downloader: Downloader) {
        self.downloaderTask = downloaderTask
        self.downloader = downloader
    }

    func startDownload() {
        downloader.addDownloadTask(task: downloaderTask)
    }
}

extension DownloadServiceOperationImpl: DownloadServiceOperation {

    func downloadableIdentifier() -> String {
        return downloaderTask.uniqueIdentifier
    }

    func downloadURL() -> URL {
        return downloaderTask.downloadURL
    }

    func pauseDownload() {
        downloader.pauseDownloadTask(task: downloaderTask)
    }

    func resumeDownload() {
        downloader.resumeDownloadTask(task: downloaderTask)
    }

    func cancelDownload() {
        downloader.cancelTask(task: downloaderTask)
    }

    func registerForProgressUpdates() {
//        downloader.
    }
}

extension DownloadServiceOperationImpl: DownloaderDelegate {
    func downloadRequestDidUpdateProgress(downloadModel: DownloadModel, index: Int) {

    }

    func downloadRequestDidPopulatedInterruptedTasks(downloadModel: [DownloadModel]) {

    }

    func downloadRequestStarted(downloadModel: DownloadModel, index: Int) {

    }

    func downloadRequestDidPaused(downloadModel: DownloadModel, index: Int) {

    }

    func downloadRequestDidResumed(downloadModel: DownloadModel, index: Int) {

    }

    func downloadRequestDidRetry(downloadModel: DownloadModel, index: Int) {

    }

    func downloadRequestCanceled(downloadModel: DownloadModel, index: Int) {

    }

    func downloadRequestFinished(downloadModel: DownloadModel, index: Int) {

    }

    func downloadRequestDidFailedWithError(error: NSError, downloadModel: DownloadModel, index: Int) {

    }
    
}
