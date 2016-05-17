import Foundation
import UIKit

public typealias VoidCompletion = () -> Void
public typealias BoolCompletion = (success: Bool) -> Void
public typealias ErrorCompletion = (errorOptional: NSError?) -> Void
public typealias ImageCompletion = (image: UIImage, errorOptional: NSError?) -> Void
public typealias DownloadDestinationCompletion = (donwloadFileTemporaryLocation: NSURL) -> NSURL
public typealias DownloadProgressCompletion = (bytesRead: Int64, totalBytesRead: Int64, totalBytesExpectedToRead: Int64) -> Void
public typealias VoidOptionalCompletion = (() -> Void)?
public typealias JSONResponseCompletion = (responseOptional: AnyObject?, errorOptional: NSError?) -> Void
public typealias DataResponseCompletion = (dataOptional: NSData?, errorOptional: NSError?) -> Void
public typealias ImageResponseCompletion = (imageURL: String, image: UIImage?, error: NSError?) -> Void
public typealias ProgressUpdate = (progress: CGFloat) -> Void