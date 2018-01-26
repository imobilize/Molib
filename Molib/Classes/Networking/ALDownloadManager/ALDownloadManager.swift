import UIKit


typealias ALDownloadCompleteClose = (_ info: ALDownloadInfo?) -> Void

class ALDownloadManager: NSObject {

    lazy var session: URLSession = {

        let config = URLSessionConfiguration.background(withIdentifier: "\(Bundle.main.bundleIdentifier!).background")

        return URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
    }()
    
    var downloadInfoArray: Array<ALDownloadInfo>?
    
    var completeClose: ALDownloadCompleteClose?
    
    
    override init() {

        downloadInfoArray = Array<ALDownloadInfo>()

        super.init()

        ALDownloadNoteCenter.addObserver(self, selector: #selector(taskComplete(notification:)),name: Notification.Name.Info.DidComplete, object: nil)
    }
    

    @discardableResult 
    func download(downloadable: Downloadable) -> ALDownloadInfo {

        var downloadInfo: ALDownloadInfo

        if let info = self.downloadInfoForURL(url: downloadable.url()) {
            downloadInfo = info
        } else {
            downloadInfo = createDownload(forDownloadable: downloadable)
        }

        downloadInfo.download()

        return downloadInfo
    }

    func suspend(url: URL) {
        let info = self.downloadInfoForURL(url: url)
        info?.cancel()
    }

    func remove(url: URL) {
        self.removeInfoForURL(url: url)
    }

    func suspendAll() {
        self.downloadInfoArray = self.downloadInfoArray?.map({ (info) -> ALDownloadInfo in
            if  info.state == ALDownloadState.Canceled || info.state == ALDownloadState.Completed {}
            else{
                info.cancel()
            }
            return info
        })
    }

    func resumeAll(){
        self.downloadInfoArray = self.downloadInfoArray?.map({ (info) -> ALDownloadInfo in
            if  info.state == ALDownloadState.Downloading || info.state == ALDownloadState.Completed {}
            else{
                info.download()
            }
            return info
        })
    }

    func resumeFirstWillResume() {
        let willInfo = self.downloadInfoArray?.first(where: { (info) -> Bool in
            info.state == ALDownloadState.Failed
        })
        willInfo?.download()
    }

    func removeAll(urls: Array<URL>) {
        urls.forEach { (url) in
            remove(url: url)
        }
    }
    

    func downloadInfoForURL(url: URL) -> ALDownloadInfo? {

        var downloadInfo: ALDownloadInfo? = nil

        if let info = self.downloadInfoArray?.filter({ (info) -> Bool in
            info.downloadurl == url
        }).first {
            downloadInfo = info
        }

        return downloadInfo
    }

    func createDownload(forDownloadable downloadable: Downloadable) -> ALDownloadInfo {

        let info = ALDownloadInfo(manager: session, downloadable: downloadable)
        self.downloadInfoArray?.append(info)
        return info
    }

    func changeWaitState(completeClose: ALDownloadCompleteClose?) {
        self.completeClose = completeClose
            var isDownloadFirst = false
            self.downloadInfoArray = self.downloadInfoArray?.map({ (info) -> ALDownloadInfo in
                if isDownloadFirst == false {
                    if info.state == ALDownloadState.Downloading {
                    isDownloadFirst = true
                        return info
                    }
                }
                if info.state == ALDownloadState.Completed {}
                else{
                    info.hangup()
                }
                return info
            })
            if isDownloadFirst == false {
                   resumeFirstWillResume()
            }
    }

    func changeDownloadState() {
        self.downloadInfoArray = self.downloadInfoArray?.map({ (info) -> ALDownloadInfo in
            if  info.state == ALDownloadState.Downloading || info.state == ALDownloadState.Completed{}
            else{
                info.download()
            }
            return info
        })
    }

    @objc func taskComplete(notification: Notification)  {
        if let info = notification.userInfo, let url = info["url"] as? URL {
            let info = downloadInfoForURL(url: url)
            info?.state = ALDownloadState.Completed
            if let close = self.completeClose {
                 close(info)
            }
            resumeFirstWillResume()
        }
    }

    func removeInfoForURL(url: URL)  {
        if let info = self.downloadInfoArray?.filter({ (info) -> Bool in
            info.downloadurl == url
        }).first {
            info.remove()
            if let alindex = self.downloadInfoArray?.index(of: info) {
                self.downloadInfoArray?.remove(at: alindex)
            }
        }
    }

    deinit{
        ALDownloadNoteCenter.removeObserver(self)
    }
}
