import Foundation
import UIKit

typealias VoidCompletion = () -> Void
typealias BoolCompletion = (success: Bool) -> Void
typealias ErrorCompletion = (errorOptional: NSError?) -> Void
typealias ImageCompletion = (image: UIImage, errorOptional: NSError?) -> Void
typealias VoidOptionalCompletion = (() -> Void)?
typealias JSONResponseCompletion = (responseOptional: AnyObject?, errorOptional: NSError?) -> Void
typealias DataResponseCompletion = (dataOptional: NSData?, errorOptional: NSError?) -> Void
typealias ImageResponseCompletion = (imageURL: String, image: UIImage?, error: NSError?) -> Void
typealias ProgressUpdate = (progress: CGFloat) -> Void