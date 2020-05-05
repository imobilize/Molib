import Foundation

public protocol Downloadable {

    func downloadIdentifier() -> String

    func downloadName() -> String

    func url() -> URL

    func localURL() -> URL
}


public typealias DownloadServiceOperationStateUpdate = (_ serviceOperation: DownloadServiceOperation, _ state: DownloadServiceOperationState) -> Void
public typealias DownloadServiceOperationProgressUpdate = (_ serviceOperation: DownloadServiceOperation, _ progress: Float) -> Void

public enum DownloadServiceOperationState {

    case NotStarted
    case Downloading
    case Paused
    case Failed
    case Finished
}


public protocol DownloadService {

    @discardableResult func enqueueDownload(downloadable: Downloadable) -> DownloadServiceOperation

    @discardableResult func resumeDownload(downloadable: Downloadable) -> DownloadServiceOperation

    func currentDownloadServiceOperations() -> [DownloadServiceOperation]
}

public protocol DownloadServiceOperation {

    var downloadable: Downloadable { get }

    func pauseDownload()

    func resumeDownload()

    func cancelDownload()

    func register(forStateUpdate update: @escaping DownloadServiceOperationStateUpdate)

    func register(forProgressUpdate update: @escaping DownloadServiceOperationProgressUpdate)
}

