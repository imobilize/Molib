import Foundation
import UIKit

public typealias VoidCompletion = () -> Void
public typealias BoolCompletion = (success: Bool) -> Void
public typealias ErrorCompletion = (errorOptional: NSError?) -> Void
public typealias ImageCompletion = (image: UIImage, errorOptional: NSError?) -> Void
public typealias DownloadCompletion = (fileLocation: NSURL, URLResponse: NSURLResponse) -> Void
public typealias VoidOptionalCompletion = (() -> Void)?
public typealias JSONResponseCompletion = (responseOptional: AnyObject?, errorOptional: NSError?) -> Void
public typealias DataResponseCompletion = (dataOptional: NSData?, errorOptional: NSError?) -> Void
public typealias ImageResponseCompletion = (imageURL: String, image: UIImage?, error: NSError?) -> Void
public typealias ProgressUpdate = (progress: CGFloat) -> Void