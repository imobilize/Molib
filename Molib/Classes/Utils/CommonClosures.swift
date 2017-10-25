import Foundation
import UIKit

public typealias VoidCompletion = () -> Void
public typealias BoolCompletion = (_ success: Bool) -> Void
public typealias ErrorCompletion = (_ errorOptional: NSError?) -> Void
public typealias ImageCompletion = (_ image: UIImage, _ errorOptional: Error?) -> Void
public typealias VoidOptionalCompletion = (() -> Void)?
public typealias JSONResponseCompletion = (_ responseOptional: AnyObject?, _ errorOptional: Error?) -> Void
public typealias DataResponseCompletion = (_ dataOptional: Data?, _ errorOptional: Error?) -> Void
public typealias ImageResponseCompletion = (_ imageURL: String, _ image: UIImage?, _ error: Error?) -> Void
public typealias ProgressUpdate = (_ progress: CGFloat) -> Void



public typealias DownloadCompletion = (_ downloadModel: MODownloadModel, _ errorOptional: Error?) -> Void

public typealias DownloadLocation = (_ downloadModel: MODownloadModel, _ donwloadFileTemporaryLocation: URL) -> URL
public typealias DownloadLocationCompletion = (_ fileLocation: URL) -> URL

public typealias DownloadOperationCompletion = (_ request: NetworkDownloadRequest) -> DownloadOperation?
public typealias DownloadProgress = (_ bytesRead: Int64, _ totalBytesRead: Int64, _ totalBytesExpectedToRead: Int64) -> Void
public typealias DownloadProgressCompletion = (_ downloadModel: MODownloadModel) -> Void

