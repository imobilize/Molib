
import Foundation
import UIKit

public typealias ImageResponseCompletion = (_ imageURL: String, _ image: UIImage?, _ error: Error?) -> Void
public typealias ImageCompletion = (_ image: UIImage, _ errorOptional: Error?) -> Void

enum ImageLoadType {
    case Normal
    case RefreshCache
    case AVAssetThumbnail
}

public protocol ImageLoader {
    
    func enqueueImageView(imageView: UIImageView, withURL imageURL: String, placeholder:String?, refreshCache: Bool)

    func enqueueImageView(imageView: UIImageView, withURL imageURL: String, placeholder:String?)
    
    func enqueueImageView(imageView: UIImageView, withAVAssetMediaURL mediaURL: String, placeholder: String?)
    
    func dequeueImageView(imageView: UIImageView)
    
    func loadImage(src: String, completion: @escaping ImageResponseCompletion) -> NetworkOperation?

    func dequeueAll()
}

public protocol ImageService {

    func enqueueImageRequest(request: ImageRequest) -> NetworkOperation

    func enqueueImageRequestRefreshingCache(request: ImageRequest) -> NetworkOperation
}

public protocol ImageRequest {

    var urlRequest: URLRequest { get }

    func handleResponse(imageURL: String, image: UIImage?, error: Error?)
}
