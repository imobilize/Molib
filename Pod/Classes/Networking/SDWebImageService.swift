
import Foundation
import SDWebImage

public class SDWebImageService: ImageService {
    
    let imageManager = SDWebImageManager.sharedManager()
    
    public init() {}
    
    public func enqueueImageRequest(request: ImageRequest) -> Operation {
        
        let operation = imageManager.downloadImageWithURL(request.urlRequest.URL, options: SDWebImageOptions.HighPriority, progress: nil, completed: { (image: UIImage?, error: NSError?, cacheType: SDImageCacheType, success: Bool, url: NSURL!) -> Void in
            
            request.handleResponse(url.URLString, image: image, error: error)
        })
        
        return SDImageOperation(imageOperation: operation)
    }
    
    public func enqueueImageRequestBypassingCached(request: ImageRequest) -> Operation {
        
        let operation = imageManager.downloadImageWithURL(request.urlRequest.URL, options: SDWebImageOptions.RefreshCached, progress: nil, completed: { (image: UIImage?, error: NSError?, cacheType: SDImageCacheType, success: Bool, url: NSURL!) -> Void in
            
            request.handleResponse(url.URLString, image: image, error: error)
        })
        
        return SDImageOperation(imageOperation: operation)
    }
}

struct SDImageOperation: Operation {
    
    let imageOperation: SDWebImageOperation
    
    func cancel() {
        imageOperation.cancel()
    }
}
