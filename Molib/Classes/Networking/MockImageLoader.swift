import Foundation
import UIKit

class LocalImageLoader: ImageLoader {
    
    var replacementDictionary: [String: String]
    let bundle: Bundle
    
    init(bundle: Bundle) {
        self.bundle = bundle
        self.replacementDictionary = [:]
    }
    
    func enqueueImageView(imageView: UIImageView, withURL imageURL: String, placeholder: String?, refreshCache: Bool) {
        
        var image: UIImage?
        let replacementImageName = replacementDictionary[imageURL]
        
        if let imageName = replacementImageName {
            image = UIImage(named: imageName, in: bundle, compatibleWith: nil)
        } else if let placeholderImageName = placeholder {
            image = UIImage(named: placeholderImageName)
        }
        
        imageView.image = image
    }

    func enqueueImageView(imageView: UIImageView, withURL imageURL: String, placeholder: String?) {
        enqueueImageView(imageView: imageView, withURL: imageURL, placeholder: placeholder, refreshCache: false)
    }

    func enqueueImageView(imageView: UIImageView, withAVAssetMediaURL mediaURL: String, placeholder: String?) {
    
    }

    func dequeueImageView(imageView: UIImageView) {

    }

    func loadImage(src: String, completion: @escaping ImageResponseCompletion) -> NetworkOperation? {
        return MockNetworkOperation()
    }

    func dequeueAll() {
    
    }
}

class MockNetworkOperation: NetworkOperation {
    func cancel() {
    }
}
