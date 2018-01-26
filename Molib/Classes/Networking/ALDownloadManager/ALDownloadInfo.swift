import Foundation
import Alamofire

public enum ALDownloadState: Int {
    case None = 0
    case Downloading = 1
    case Suspended = 2
    case Canceled = 3
    case Failed = 4
    case Completed = 5

    init(urlSessionState: URLSessionDownloadTask.State) {
        switch urlSessionState {
        case .canceling:
            self = .Canceled
        case .completed:
            self = .Completed
        case .running:
            self = .Downloading
        case .suspended:
            self = .Suspended
        }
    }
}

typealias ALDownloadStateBlock = (_ state: ALDownloadState)-> Void
typealias ALDownloadProgressBlock = (_ progress: Float)-> Void


class ALDownloadInfo: NSObject {

    private let session: URLSession

    let downloadable: Downloadable

    var downloadurl: URL {
        return downloadable.url()
    }

    var destinationURL: URL {
        return downloadable.localURL()
    }

    private var downloadRequest: URLSessionDownloadTask?

    var cancelledData: Data?

    private var stateChangeBlock: ALDownloadStateBlock?
    private var progressChangeBlock: ALDownloadProgressBlock?

    var state: ALDownloadState? = ALDownloadState.None {
        willSet{
            if let stateBlock = self.stateChangeBlock,let newState = newValue {
                stateBlock(newState)
                if newValue == ALDownloadState.Failed {
                    self.progress = 0
                }
            }
        }
        didSet{}
    }

    var progress: Float? {
        willSet{
            if let progressBlock = self.progressChangeBlock,let newProgress = newValue {
                progressBlock(newProgress)
            }
        }
        didSet{}
    }

    init(manager: URLSession, downloadable: Downloadable) {
        self.session = manager
        self.downloadable = downloadable
    }
    
    func download() {

        if let resumeData = cancelledData {

            downloadRequest = session.downloadTask(withResumeData: resumeData)

        } else {

            downloadRequest = session.downloadTask(with: downloadable.url())
        }
        
        downloadRequest?.resume()

        self.state = ALDownloadState.Downloading
    }

    func suspend() {
        downloadRequest?.suspend()
        updateState()
    }

    func cancel() {
        downloadRequest?.cancel(byProducingResumeData: { (resumeData) in
            self.cancelledData = resumeData
        })
        updateState()
    }

    func hangup() {
        downloadRequest?.cancel()
        updateState()
    }
    
    func remove() {
        downloadRequest?.cancel()
        updateState()
    }

    func updateState() {
        if let state = downloadRequest?.state {
            self.state = ALDownloadState(urlSessionState: state)
        }
    }

    @discardableResult
    func setDownloadProgressListener(_ listener: ALDownloadProgressBlock?) -> Self  {

        self.progressChangeBlock = listener

        if let block = listener, let progress = self.progress {
            block(progress)
        }
        return self
    }

    @discardableResult
    func setStateChangeListener(_ listener: ALDownloadStateBlock?) -> Self  {

        self.stateChangeBlock = listener

        if let block = listener, let state = self.state {
            block(state)
        }
        return self
    }
}
