import Foundation
import UIKit

public typealias VoidCompletion = () -> Void
public typealias BoolCompletion = (success: Bool) -> Void
public typealias ErrorCompletion = (errorOptional: NSError?) -> Void
public typealias ImageCompletion = (image: UIImage, errorOptional: NSError?) -> Void
public typealias VoidOptionalCompletion = (() -> Void)?
public typealias JSONResponseCompletion = (responseOptional: AnyObject?, errorOptional: NSError?) -> Void
public typealias DataResponseCompletion = (dataOptional: NSData?, errorOptional: NSError?) -> Void
public typealias ImageResponseCompletion = (imageURL: String, image: UIImage?, error: NSError?) -> Void
public typealias ProgressUpdate = (progress: CGFloat) -> Void



public typealias DownloadCompletion = (downloadModel: MODownloadModel, errorOptional: NSError?) -> Void

public typealias DownloadLocation = (downloadModel: MODownloadModel, donwloadFileTemporaryLocation: NSURL) -> NSURL
public typealias DownloadLocationCompletion = (fileLocation: NSURL) -> NSURL

public typealias DownloadOperationCompletion = (request: NetworkDownloadRequest) -> DownloadOperation?
public typealias DownloadProgress = (bytesRead: Int64, totalBytesRead: Int64, totalBytesExpectedToRead: Int64) -> Void
public typealias DownloadProgressCompletion = (downloadModel: MODownloadModel) -> Void

