
import Foundation

class MockRequestQueue {
    
    private static var responses: Dictionary<String, String> = Dictionary<String, String>()
    
    class func enqueueJsonResponseForRequestURL(urlString: String, responseFile: String) {
        
        let bundle = NSBundle(forClass: self)
        
        let filePath = bundle.pathForResource(responseFile, ofType: "json")
        
        responses[urlString] = filePath
    }
    
    class func dequeueResponeFileForRequestURL(urlString: String) -> String? {
    
        let responseURL = responses[urlString]
    
//        responses.removeValueForKey(urlString)
    
        return responseURL
    }
}


class MockNetworkService : NetworkService {
    
    func enqueueNetworkRequest(request: NetworkRequest) -> Operation? {
        
        let operation = MockRequestOperation(request: request.urlRequest)
        
        let completion = completionForRequest(request)
        
        operation.startConnection(completion)
        
        return operation
    }
    
    func enqueueNetworkUploadRequest(request: NetworkRequest, fileURL: NSURL) -> UploadOperation? {
        
        let operation = MockRequestOperation(request: request.urlRequest)
        
        let completion = completionForRequest(request)
        
        operation.startConnection(completion)
        
        return operation

    }
    
    func enqueueNetworkUploadRequest(request: NetworkRequest, data: NSData) -> UploadOperation? {
        
        let operation = MockRequestOperation(request: request.urlRequest)
        
        let completion = completionForRequest(request)
        
        operation.startConnection(completion)
        
        return operation

    }
}

struct MockRequestOperation: UploadOperation {
    
    let request: NSURLRequest
    let log = LoggerFactory.logger()
    
    init(request: NSURLRequest) {
        self.request = request
    }
    
    func startConnection(completion: DataResponseCompletion) {
        
        print("Requesting url: \(request.URLString)")
        
        let fileURL = MockRequestQueue.dequeueResponeFileForRequestURL(request.URLString)

        print("Found file url: \(fileURL)")

        if let url = fileURL {
        
            print("Found file url for request: \(fileURL) \n")

            let data = NSData(contentsOfFile: url)
            
            completion(dataOptional: data, errorOptional: nil)
            
        } else {
            
            print("File url for request not found\n")

            let error = NSError(domain: "Network", code: 101, userInfo: nil)
            
            completion(dataOptional: nil, errorOptional: error)
        }
        
    }
    
    func cancel() {
        
        
    }
    
    func pause() {
        
    }
    
    func resume() {
        
    }
    
    func registerProgressUpdate(progressUpdate: ProgressUpdate) {
        
    }
}
