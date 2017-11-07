import Foundation

public protocol DownloadService {

    func enqueueDownload(downloadable: Downloadable) -> DownloadServiceOperation

    func currentDownloadServiceOperations() -> [DownloadServiceOperation]
}

public protocol DownloadServiceOperation {

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

        let downloaderTask = DownloaderTask(downloadURL: downloadable.fileURL, downloadDestinationURL: downloadable.localFileURL, fileName: downloadable.fileName)

        downloader.addDownloadTask(task: downloaderTask)

        let downloadServiceOperation = DownloadServiceOperationImpl(downloaderTask: downloaderTask, downloader: downloader)

        currentOperations.append(downloadServiceOperation)

        return downloadServiceOperation
    }

    func currentDownloadServiceOperations() -> [DownloadServiceOperation] {
        return currentOperations
    }
}

class DownloadServiceOperationImpl: DownloadServiceOperation {

    private let downloaderTask: DownloaderTask
    private let downloader: Downloader

    init(downloaderTask: DownloaderTask, downloader: Downloader) {
        self.downloaderTask = downloaderTask
        self.downloader = downloader
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
