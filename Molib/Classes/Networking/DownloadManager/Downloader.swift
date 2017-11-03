
import Foundation
import UIKit

public struct DownloaderTask {
    let downloadURL: URL
    let downloadDestinationURL: URL
    let fileName: String

    static func ==(lhs: DownloaderTask, rhs: DownloaderTask) -> Bool {

        return rhs.downloadURL == lhs.downloadURL
    }
}

public protocol DownloaderDelegate {
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


public protocol Downloader {
    
    var delegate: DownloaderDelegate? { get set }

    func addDownloadTask(task: DownloaderTask)

    func pauseDownloadTask(task: DownloaderTask)

    func resumeDownloadTask(task: DownloaderTask)

    func retryDownloadTask(task: DownloaderTask)

    func cancelTask(task: DownloaderTask)
}
//
//
//class DownloaderImpl: NSObject {
//
//    private var sessionManager: URLSession!
//    private var downloadingArray: [DownloadModel] = []
//    private var backgroundSessionCompletionHandler: (() -> Void)?
//
//    var delegate: DownloaderDelegate?
//    
//    public init(session sessionIdentifer: String) {
//        
//        super.init()
//        
//        self.sessionManager = self.backgroundSession(sessionIdentifer: sessionIdentifer)
//        self.populateOtherDownloadTasks()
//    }
//    
//    public convenience init(session sessionIdentifer: String, delegate: DownloaderDelegate) {
//        
//        self.init(session: sessionIdentifer)
//        
//        self.delegate = delegate
//    }
//    
//    public convenience init(session sessionIdentifer: String, delegate: DownloaderDelegate, completion: (() -> Void)?) {
//     
//        self.init(session: sessionIdentifer, delegate: delegate)
//        self.backgroundSessionCompletionHandler = completion
//    }
//    
//    private func backgroundSession(sessionIdentifer: String) -> URLSession {
//
//        var urlSession: URLSession
//
//        DispatchQueue.once {
//
//            let sessionConfiguration = URLSessionConfiguration.background(withIdentifier: sessionIdentifer)
//            urlSession = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
//        }
//
//        return urlSession
//    }
//
//    private func populateOtherDownloadTasks() {
//
//        let downloadTasks = self.downloadTasks()
//
//        for object in downloadTasks {
//
//            let downloadTask = object as! URLSessionDownloadTask
//            let taskDescComponents: [String] = downloadTask.taskDescription!.components(separatedBy: ",")
//
//            let id = taskDescComponents.first!
//            let fileName = taskDescComponents[1]
//            let fileURL = taskDescComponents.last!
//
//            let downloadModel = DownloadModel.init(id: id, fileName: fileName, fileURL: fileURL)
//            downloadModel.task = downloadTask
//            downloadModel.startTime = Date()
//
//            if downloadTask.state == .running {
//                downloadModel.status = TaskStatus.Downloading.description()
//                downloadingArray.append(downloadModel)
//            } else if(downloadTask.state == .suspended) {
//                downloadModel.status = TaskStatus.Paused.description()
//                downloadingArray.append(downloadModel)
//            } else {
//                downloadModel.status = TaskStatus.Failed.description()
//            }
//        }
//    }
//
//    class func destinationPathForFileName(fileName: String) -> String {
//        return DownloadUtility.baseFilePath + "/" + fileName
//    }
//
//    var fileManager: FileManager {
//        get { return FileManager.`default` }
//    }
//}
//
//// MARK: Private Helper functions
//
//extension DownloaderImpl {
//    
//    private func downloadTasks() -> Array<URLSessionDownloadTask> {
//        return self.tasksForKeyPath(keyPath: "downloadTasks")
//    }
//    
//    private func tasksForKeyPath(keyPath: String) -> Array<URLSessionDownloadTask> {
//        var tasks = Array<URLSessionDownloadTask>()
//
//        let semaphore = DispatchSemaphore(value: 0)
//
//        sessionManager.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) -> Void in
//
//            if keyPath == "downloadTasks" {
//                if downloadTasks.count > 0 {
//                    tasks = downloadTasks
//                    debugPrint("pending tasks \(tasks)")
//                }
//            }
//            
//            semaphore.signal()
//        }
//        
//        semaphore.wait()
//        return tasks
//    }
//    
//    private func isValidResumeData(resumeData: Data?) -> Bool {
//        
//        guard let data = resumeData, data.count > 0 else {
//            return false
//        }
//        
//        do {
//            var resumeDictionary : AnyObject!
//            resumeDictionary = try PropertyListSerialization.propertyList(from: resumeData!, options: .Immutable, format: nil) as AnyObject
//            var localFilePath : String? = resumeDictionary?.object("URLSessionResumeInfoLocalPath") as? String
//            
//            if localFilePath == nil || localFilePath?.length < 1 {
//                localFilePath = NSTemporaryDirectory() + (resumeDictionary["URLSessionResumeInfoTempFileName"] as! String)
//            }
//            
//            let fileManager = self.fileManager
//            debugPrint("resume data file exists: \(fileManager.fileExists(atPath: localFilePath! ))")
//            return fileManager.fileExists(atPath: localFilePath!)
//        } catch let error as NSError {
//            debugPrint("resume data is nil: \(error)")
//            return false
//        }
//    }
//}
//
//extension DownloaderImpl: URLSessionDelegate {
//    
//    func URLSession(session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
//        
//        for (index, downloadModel) in self.downloadingArray.enumerated() {
//          
//            if downloadTask.isEqual(downloadModel.task) {
//                DispatchQueue.main.async {
//
//                    let receivedBytesCount = Double(downloadTask.countOfBytesReceived)
//                    let totalBytesCount = Double(downloadTask.countOfBytesExpectedToReceive)
//                    let progress = Float(receivedBytesCount / totalBytesCount)
//                    
//                    let taskStartedDate = downloadModel.startTime != nil ? downloadModel.startTime! : Date()
//                    let timeInterval = taskStartedDate.timeIntervalSinceNow
//                    let downloadTime = TimeInterval(-1 * timeInterval)
//                    
//                    let speed = Float(totalBytesWritten) / Float(downloadTime)
//                    
//                    let remainingContentLength = totalBytesExpectedToWrite - totalBytesWritten
//                    
//                    let remainingTime = remainingContentLength / Int64(speed)
//                    let hours = Int(remainingTime) / 3600
//                    let minutes = (Int(remainingTime) - hours * 3600) / 60
//                    let seconds = Int(remainingTime) - hours * 3600 - minutes * 60
//                    
//                    let totalFileSize = DownloadUtility.calculateFileSizeInUnit(contentLength: totalBytesExpectedToWrite)
//                    let totalFileSizeUnit = DownloadUtility.calculateUnit(contentLength: totalBytesExpectedToWrite)
//                    
//                    let downloadedFileSize = DownloadUtility.calculateFileSizeInUnit(contentLength: totalBytesWritten)
//                    let downloadedSizeUnit = DownloadUtility.calculateUnit(contentLength: totalBytesWritten)
//                    
//                    let speedSize = DownloadUtility.calculateFileSizeInUnit(contentLength: Int64(speed))
//                    let speedUnit = DownloadUtility.calculateUnit(contentLength: Int64(speed))
//                    
//                    downloadModel.remainingTime = (hours, minutes, seconds)
//                    downloadModel.file = (totalFileSize, totalFileSizeUnit as String)
//                    downloadModel.downloadedFile = (downloadedFileSize, downloadedSizeUnit as String)
//                    downloadModel.speed = (speedSize, speedUnit as String)
//                    downloadModel.progress = progress
//                    
//                    self.downloadingArray[index] = downloadModel
//                    
//                    self.delegate?.downloadRequestDidUpdateProgress(downloadModel: downloadModel, index: index)
//                }
//                break
//            }
//        }
//    }
//    
//    func URLSession(session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingToURL location: URL) {
//      
//        for (index, downloadModel) in downloadingArray.enumerated() {
//        
//            if downloadTask.isEqual(downloadModel.task) {
//            
//                let fileName = downloadModel.fileName as String
//                let destinationPath = DownloaderImpl.destinationPathForFileName(fileName: fileName)
//                let fileURL = URL(fileURLWithPath: destinationPath)
//                debugPrint("directory path = \(destinationPath)")
//                
//                let fileManager = FileManager.`default`
//                
//                do {
//                    try fileManager.moveItem(at: location, to: fileURL)
//                } catch let error as NSError {
//                
//                    //TODO: handle errors like file already exists
//                    debugPrint("Error while moving downloaded file to destination path:\(error)")
//                    DispatchQueue.main.async {
//                        self.delegate?.downloadRequestDidFailedWithError(error: error, downloadModel: downloadModel, index: index)
//                    }
//                }
//                
//                break
//            }
//        }
//    }
//    
//    func URLSession(session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
//        debugPrint("task id: \(task.taskIdentifier)")
//        /***** Any interrupted tasks due to any reason will be populated in failed state after init *****/
//        if (error?.userInfo[URLErrorBackgroundTaskCancelledReasonKey] as AnyObject).integerValue == URLErrorCancelledReasonUserForceQuitApplication || (error?.userInfo[URLErrorBackgroundTaskCancelledReasonKey] as AnyObject).integerValue == URLErrorCancelledReasonBackgroundUpdatesDisabled {
//            
//            let downloadTask = task as! URLSessionDownloadTask
//            let taskDescComponents: [String] = downloadTask.taskDescription!.components(separatedBy: ",")
//            let id = taskDescComponents.first!
//            let fileName = taskDescComponents[1]
//            let fileURL = taskDescComponents.last!
//            
//            let downloadModel = DownloadModel.init(id: id, fileName: fileName, fileURL: fileURL)
//            downloadModel.status = TaskStatus.Failed.description()
//            downloadModel.task = downloadTask
//            
//            let resumeData = error?.userInfo[URLSessionDownloadTaskResumeData] as? Data
//            
//            DispatchQueue.main.async {
//                var newTask = task
//                if self.isValidResumeData(resumeData) == true {
//                    newTask = self.sessionManager.downloadTaskWithResumeData(resumeData!)
//                } else if let url = URL(string: fileURL) {
//
//                    newTask = self.sessionManager.downloadTask(with: url)
//                }
//                
//                newTask.taskDescription = task.taskDescription
//                downloadModel.task = newTask as? URLSessionDownloadTask
//                
//                self.downloadingArray.append(downloadModel)
//                
//                self.delegate?.downloadRequestDidPopulatedInterruptedTasks(downloadModel: self.downloadingArray)
//            }
//            
//        } else {
//            for(index, object) in self.downloadingArray.enumerated() {
//              
//                let downloadModel = object
//                
//                if task.isEqual(downloadModel.task) {
//                   
//                    if error?.code == URLError.cancelled.rawValue || error == nil {
//                    
//                        DispatchQueue.main.async {
//
//                            self.downloadingArray.remove(at: index)
//                            
//                            if error == nil {
//                                
//                                let fileName = downloadModel.fileName
//
//                                let destinationPath = DownloaderImpl.destinationPathForFileName(fileName: fileName)
//                                
//                                downloadModel.localFileURL = destinationPath
//                                
//                                self.delegate?.downloadRequestFinished(downloadModel: downloadModel, index: index)
//                                
//                            } else {
//                                
//                                self.delegate?.downloadRequestCanceled(downloadModel: downloadModel, index: index)
//                            }
//                        }
//                        
//                    } else {
//                        
//                        let resumeData = error?.userInfo[URLSessionDownloadTaskResumeData] as? Data
//
//                        DispatchQueue.main.async {
//
//                            var newTask = task
//                            if self.isValidResumeData(resumeData) == true {
//                                newTask = self.sessionManager.downloadTaskWithResumeData(resumeData!)
//                            } else {
//                                newTask = self.sessionManager.downloadTask(with: URL(string: downloadModel.fileURL)!)
//                            }
//                            
//                            newTask.taskDescription = task.taskDescription
//                            downloadModel.status = TaskStatus.Failed.description()
//                            downloadModel.task = newTask as? URLSessionDownloadTask
//                            
//                            self.downloadingArray[index] = downloadModel
//                            
//                            if let error = error {
//                                self.delegate?.downloadRequestDidFailedWithError(error: error, downloadModel: downloadModel, index: index)
//                            } else {
//                                let error: NSError = NSError(domain: "MZDownloadManagerDomain", code: 1000, userInfo: [NSLocalizedDescriptionKey : "Unknown error occurred"])
//                                
//                                self.delegate?.downloadRequestDidFailedWithError(error: error, downloadModel: downloadModel, index: index)
//                            }
//                            
//                        }
//                    }
//                    break;
//                }
//            }
//        }
//    }
//    
//    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
//        
//        if let backgroundCompletion = self.backgroundSessionCompletionHandler {
//            DispatchQueue.main.async {
//
//                backgroundCompletion()
//            }
//        }
//        debugPrint("All tasks are finished")
//        
//    }
//}
//
////MARK: Public Helper Functions
//
//#if os(iOS)
//
//extension DownloaderImpl : Downloader {
//    
//    public func addDownloadTask(id: String, fileName: String, fileURL: String) {
//        
//        let url = URL(string: fileURL as String)!
//        let request = URLRequest(url: url)
//        
//        let downloadTask = sessionManager.downloadTask(with: request)
//        downloadTask.taskDescription = [id, fileName, fileURL].joined(separator: ",")
//        downloadTask.resume()
//        
//        debugPrint("session manager:\(sessionManager) url:\(url) request:\(request)")
//        
//        let downloadModel = DownloadModel.init(id: id, fileName: fileName, fileURL: fileURL)
//        downloadModel.startTime = Date()
//        downloadModel.status = TaskStatus.Downloading.description()
//        downloadModel.task = downloadTask
//        
//        downloadingArray.append(downloadModel)
//        delegate?.downloadRequestStarted(downloadModel: downloadModel, index: downloadingArray.count - 1)
//    }
//    
//    public func pauseDownloadTaskAtIndex(index: Int) {
//        
//        let downloadModel = downloadingArray[index]
//        
//        guard downloadModel.status != TaskStatus.Paused.description() else {
//            return
//        }
//        
//        let downloadTask = downloadModel.task
//        downloadTask!.suspend()
//        downloadModel.status = TaskStatus.Paused.description()
//        downloadModel.startTime = Date()
//        
//        downloadingArray[index] = downloadModel
//        
//        delegate?.downloadRequestDidPaused(downloadModel: downloadModel, index: index)
//    }
//    
//    public func resumeDownloadTaskAtIndex(index: Int) {
//        
//        let downloadModel = downloadingArray[index]
//        
//        guard downloadModel.status != TaskStatus.Downloading.description() else {
//            return
//        }
//        
//        let downloadTask = downloadModel.task
//        downloadTask!.resume()
//        downloadModel.startTime = Date()
//        downloadModel.status = TaskStatus.Downloading.description()
//        
//        downloadingArray[index] = downloadModel
//        
//        delegate?.downloadRequestDidResumed(downloadModel: downloadModel, index: index)
//    }
//    
//    public func retryDownloadTaskAtIndex(index: Int) {
//        let downloadModel = downloadingArray[index]
//        
//        guard downloadModel.status != TaskStatus.Downloading.description() else {
//            return
//        }
//        
//        let downloadTask = downloadModel.task
//        
//        downloadTask!.resume()
//        downloadModel.status = TaskStatus.Downloading.description()
//        downloadModel.startTime = Date()
//        downloadModel.task = downloadTask
//        
//        downloadingArray[index] = downloadModel
//    }
//    
//    public func cancelTaskAtIndex(index: Int) {
//        
//        let downloadInfo = downloadingArray[index]
//        let downloadTask = downloadInfo.task
//        downloadTask!.cancel()
//    }
//    
//    public func presentNotificationForDownload(notifAction: String, notifBody: String) {
//        let application = UIApplication.shared
//        let applicationState = application.applicationState
//        
//        if applicationState == UIApplicationState.background {
//            
//            #if os(iOS)
//                
//            let localNotification = UILocalNotification()
//            localNotification.alertBody = notifBody
//            localNotification.alertAction = notifAction
//            localNotification.soundName = UILocalNotificationDefaultSoundName
//            localNotification.applicationIconBadgeNumber += 1
//            application.presentLocalNotificationNow(localNotification)
//            
//            #endif
//        }
//    }
//}
//
//#endif

