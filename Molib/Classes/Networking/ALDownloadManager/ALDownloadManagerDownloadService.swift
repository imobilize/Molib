import Foundation

extension ALDownloadManager: URLSessionDelegate, URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {

        if totalBytesExpectedToWrite > 0 {

            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            debugPrint("Progress \(downloadTask) \(progress)")

            if let downloadURL = downloadTask.currentRequest?.url, let info = downloadInfoForURL(url: downloadURL) {
                info.progress = progress
            }
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

        debugPrint("Download finished: \(location)")
        let fileManager = FileManager.default

        if let downloadURL = downloadTask.currentRequest?.url, let info = downloadInfoForURL(url: downloadURL) {

            do {

                if fileManager.fileExists(atPath: info.destinationURL.absoluteString) {
                    try fileManager.removeItem(at: info.destinationURL)
                }

                try fileManager.moveItem(at: location, to: info.destinationURL)

                info.state = ALDownloadState.Completed

                ALDownloadNoteCenter.post(name: Notification.Name.Info.DidComplete, object: self, userInfo: ["url": downloadURL])
            } catch {

                var debugMessage = "Error trying to move download: " + downloadURL.absoluteString
                    debugMessage += " to url: " + info.destinationURL.absoluteString + " " + error.localizedDescription

                debugPrint(debugMessage)

                info.state = ALDownloadState.Failed
            }
        }

        try? fileManager.removeItem(at: location)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {

        debugPrint("Task completed: \(task), error: \(String(describing: error))")

        if let downloadURL = task.currentRequest?.url, let info = downloadInfoForURL(url: downloadURL) {
            info.state = ALDownloadState.Failed
        }
    }
}


extension ALDownloadManager: DownloadService {

    func enqueueDownload(downloadable: Downloadable) -> DownloadServiceOperation {
        return download(downloadable: downloadable)
    }

    func resumeDownload(downloadable: Downloadable) -> DownloadServiceOperation {

        var downloadInfo: ALDownloadInfo

        if let info = downloadInfoForURL(url: downloadable.url()) {

            info.resumeDownload()

            downloadInfo = info
        } else {

            downloadInfo = createDownload(forDownloadable: downloadable)
            downloadInfo.download()
        }

        return downloadInfo
    }

    func currentDownloadServiceOperations() -> [DownloadServiceOperation] {
        if let downloads = downloadInfoArray {
            return downloads
        }

        return []
    }
}


extension ALDownloadInfo: DownloadServiceOperation {

    func pauseDownload() {
        suspend()
    }

    func resumeDownload() {
        download()
    }

    func cancelDownload() {
        cancel()
    }

    func register(forStateUpdate update: @escaping (DownloadServiceOperation, DownloadServiceOperationState) -> Void) {

        setStateChangeListener {  [weak self](alState) in

            if let strongSelf = self {

                var downloadState: DownloadServiceOperationState

                switch alState {
                case .Canceled:
                    downloadState = .Paused
                case .Completed:
                    downloadState = .Finished
                case .Downloading:
                    downloadState = .Downloading
                case .None:
                    downloadState = .NotStarted
                case .Suspended:
                    downloadState = .Paused
                case .Failed:
                    downloadState = .Failed
                }

                update(strongSelf, downloadState)
            }
        }
    }

    func register(forProgressUpdate update: @escaping (DownloadServiceOperation, Float) -> Void) {
        setDownloadProgressListener { [weak self](value) in

            if let strongSelf = self {
                update(strongSelf, value)
            }
        }
    }
}
