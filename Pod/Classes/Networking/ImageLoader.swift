
import Foundation
import UIKit

public protocol ImageLoader {
    
    func enqueueImageView(imageView: UIImageView, withURL imageURL: String, placeholder:String?, refreshCache: Bool)

    func enqueueImageView(imageView: UIImageView, withURL imageURL: String, placeholder:String?)
    
    func dequeueImageView(imageView: UIImageView)
    
    func loadImage(src: String, completion: ImageResponseCompletion) -> Operation?

    func dequeueAll()
}


public class AsyncImageLoader: ImageLoader {

    let imageService: ImageService
    var currentTag: Int
    var loadingCache: Dictionary<String, Operation>
    
    public init(imageService: ImageService) {
    
        self.currentTag = 0
        self.imageService = imageService
        self.loadingCache = Dictionary<String, Operation>()
    }
    
    public func enqueueImageView(imageView: UIImageView, withURL imageURL: String, placeholder:String?, refreshCache: Bool) {
        
        dequeueImageView(imageView)
        
        currentTag++
        currentTag = (self.currentTag == NSIntegerMax ? 1 : self.currentTag);
        
        imageView.tag = self.currentTag
        
        if (placeholder != nil) {
            
            imageView.image = UIImage(named: placeholder!)
        }
        
        let imageViewKey = String(format: "%ld", imageView.tag)
        
        loadImageSrc(imageURL, forImageView:imageView, identifier: imageViewKey, refreshCache: refreshCache)
        
    }

    public func enqueueImageView(imageView: UIImageView, withURL imageURL: String, placeholder:String?) {
        
        enqueueImageView(imageView, withURL: imageURL, placeholder: placeholder, refreshCache: false)
        
    }
        
    public func dequeueImageView(imageView: UIImageView) {
            
        let imageViewKey = String(format: "%ld", imageView.tag)
            
        let imageOperation = self.loadingCache[imageViewKey]
            
        if (imageOperation != nil) {
                
            imageOperation!.cancel()
                
            loadingCache.removeValueForKey(imageViewKey)
        }
    }
    
    
    public func loadImage(src: String, completion: ImageResponseCompletion) -> Operation? {
        
        var operation: Operation?
        
        if let imageRequest =  NSURLRequest.GETRequest(src) {
            
            let imageRequest = ImageRequestTask(urlRequest: imageRequest, taskCompletion: completion)
            
            let imageOperation = imageService.enqueueImageRequest(imageRequest)
            
            operation = imageOperation
        }
        
        return operation
    }

//MARK: - Private methods

    private func loadImageSrc(src: String, forImageView imageView: UIImageView, identifier: String, refreshCache: Bool) {
     
        if let imageRequest =  NSURLRequest.GETRequest(src) {
            
            let imageRequestTaskCompletion = { (imageURL: String, image: UIImage?, error: NSError?) in

                self.handleImageResponse(imageView, image: image, identifier: identifier)
            }
            
            let imageRequest = ImageRequestTask(urlRequest: imageRequest, taskCompletion: imageRequestTaskCompletion)
            
            let imageOperation: Operation
            
            if refreshCache {
                
                imageOperation = imageService.enqueueImageRequestRefreshingCache(imageRequest)
                
            } else {
                
                imageOperation = imageService.enqueueImageRequest(imageRequest)
            }
            
            loadingCache[identifier] = imageOperation
        }

    }
    
    func handleImageResponse(imageView: UIImageView, image: UIImage?, identifier: String) {
        
        if (imageView.tag == Int(identifier)) && (image != nil) {
            
            imageView.image = image
        }
    }
    
    public func dequeueAll() {
        
        for (_, imageOperation) in self.loadingCache {
            
            imageOperation.cancel()
        }
    }

}
