import Foundation
import UIKit

public class AsyncImageLoader: ImageLoader {

    let imageService: ImageService
    var currentTag: Int
    var loadingCache: Dictionary<String, NetworkOperation>

    public init(imageService: ImageService) {

        self.currentTag = 0
        self.imageService = imageService
        self.loadingCache = Dictionary<String, NetworkOperation>()
    }

    public func enqueueImageView(imageView: UIImageView, withURL imageURL: String, placeholder:String?, refreshCache: Bool) {

        dequeueImageView(imageView: imageView)

        currentTag += 1
        currentTag = (self.currentTag == NSIntegerMax ? 1 : self.currentTag);

        imageView.tag = self.currentTag

        if (placeholder != nil) {

            imageView.image = UIImage(named: placeholder!)
        }

        let imageViewKey = String(format: "%ld", imageView.tag)

        loadImageSrc(src: imageURL, forImageView:imageView, identifier: imageViewKey, loadType: refreshCache ? .RefreshCache : .Normal)

    }

    public func enqueueImageView(imageView: UIImageView, withURL imageURL: String, placeholder:String?) {

        enqueueImageView(imageView: imageView, withURL: imageURL, placeholder: placeholder, refreshCache: false)

    }

    public func enqueueImageView(imageView: UIImageView, withAVAssetMediaURL mediaURL: String, placeholder: String?) {

        dequeueImageView(imageView: imageView)

        currentTag += 1
        currentTag = (self.currentTag == NSIntegerMax ? 1 : self.currentTag);

        imageView.tag = self.currentTag

        if (placeholder != nil) {

            imageView.image = UIImage(named: placeholder!)
        }

        let imageViewKey = String(format: "%ld", imageView.tag)

        loadImageSrc(src: mediaURL, forImageView:imageView, identifier: imageViewKey, loadType: .AVAssetThumbnail)
    }

    public func dequeueImageView(imageView: UIImageView) {

        let imageViewKey = String(format: "%ld", imageView.tag)

        let imageOperation = self.loadingCache[imageViewKey]

        if (imageOperation != nil) {

            imageOperation!.cancel()

            loadingCache.removeValue(forKey: imageViewKey)
        }
    }


    public func loadVideoThumbnialImage(src: String, completion: @escaping ImageResponseCompletion) -> NetworkOperation {

        let operation = VideoThumbnailRequestOperation(mediaURL: src)

        operation.start(completion: completion)

        return operation

    }

    public func loadImage(src: String, completion: @escaping ImageResponseCompletion) -> NetworkOperation? {

        var operation: NetworkOperation?

        if let imageRequest = URLRequest(string: src) {

            let imageRequest = ImageRequestTask(urlRequest: imageRequest as URLRequest, taskCompletion: completion)

            let imageOperation = imageService.enqueueImageRequest(request: imageRequest)

            operation = imageOperation
        }

        return operation
    }

    //MARK: - Private methods

    private func loadImageSrc(src: String, forImageView imageView: UIImageView, identifier: String, loadType: ImageLoadType) {

        if let imageRequest =  URLRequest(string: src) {

            let imageRequestTaskCompletion = { (imageURL: String, image: UIImage?, error: Error?) in

                self.handleImageResponse(imageView: imageView, image: image, identifier: identifier)
            }

            let imageRequest = ImageRequestTask(urlRequest: imageRequest as URLRequest, taskCompletion: imageRequestTaskCompletion)

            let imageOperation: NetworkOperation

            switch loadType {

            case .RefreshCache:
                imageOperation = imageService.enqueueImageRequestRefreshingCache(request: imageRequest)

            case .AVAssetThumbnail:
                imageOperation = loadVideoThumbnialImage(src: src, completion: imageRequestTaskCompletion)

            default:
                imageOperation = imageService.enqueueImageRequest(request: imageRequest)

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

