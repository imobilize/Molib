import Foundation
import UIKit

public class MockImageLoader: ImageLoader {
    
    private var replacementDictionary: [String: String]
    private let bundle: Bundle
    
    public init(bundle: Bundle) {
        self.bundle = bundle
        self.replacementDictionary = [:]
    }
    
    public func enqueueImageView(imageView: UIImageView, withURL imageURL: String, placeholder: String?, refreshCache: Bool) {
        
        var image: UIImage?
        let replacementImageName = replacementDictionary[imageURL]
        
        if let imageName = replacementImageName {
            image = UIImage(named: imageName, in: bundle, compatibleWith: nil)
        } else if let placeholderImageName = placeholder {
            image = UIImage(named: placeholderImageName)
        }
        
        imageView.image = image
    }

    public func enqueueImageView(imageView: UIImageView, withURL imageURL: String, placeholder: String?) {
        enqueueImageView(imageView: imageView, withURL: imageURL, placeholder: placeholder, refreshCache: false)
    }

    public func enqueueImageView(imageView: UIImageView, withAVAssetMediaURL mediaURL: String, placeholder: String?) {
    
    }

    public func dequeueImageView(imageView: UIImageView) {

    }

    public func loadImage(src: String, completion: @escaping ImageResponseCompletion) -> NetworkOperation? {
        return MockNetworkOperation()
    }

    public func dequeueAll() {
    
    }
}

class MockNetworkOperation: NetworkOperation {
    func cancel() {
    }
}
