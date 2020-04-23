
import Foundation
import SDWebImage

public class SDWebImageService: ImageService {
    
    let imageManager = SDWebImageManager.shared
    
    public init() {}
    
    public func enqueueImageRequest(request: ImageRequest) -> NetworkOperation {
        
        let operation = imageManager.loadImage(with: request.urlRequest.url, options: SDWebImageOptions.highPriority, progress: nil) { (image, data, error, cacheType, finished, url) in

            guard let urlString = url?.absoluteString else { return }

            request.handleResponse(imageURL: urlString, image: image, error: error)
        }
        
        return SDImageOperation(imageOperation: operation!)
    }
    
    public func enqueueImageRequestRefreshingCache(request: ImageRequest) -> NetworkOperation {
        
        let options = SDWebImageOptions.refreshCached.union(.retryFailed)

        let operation = imageManager.loadImage(with: request.urlRequest.url, options: options, progress: nil) { (image, data, error, cacheType, finished, url) in
            
            guard let urlString = url?.absoluteString else { return }

            request.handleResponse(imageURL: urlString, image: image, error: error)
        }
        
        return SDImageOperation(imageOperation: operation!)
    }
}

struct SDImageOperation: NetworkOperation {
    
    let imageOperation: SDWebImageOperation
    
    func cancel() {
        imageOperation.cancel()
    }
}
