
import Foundation

public class MockRequestQueue {
    
    private static var responses: Dictionary<String, String> = Dictionary<String, String>()
    
    public class func enqueueJsonResponseForRequestURL(urlString: String, responseFile: String) {
        
        let bundle = Bundle.main
        
        let filePath = bundle.path(forResource: responseFile, ofType: "json")
        
        responses[urlString] = filePath
    }
    
    public class func dequeueResponeFileForRequestURL(urlString: String) -> String? {
    
        let responseURL = responses[urlString]
    
//        responses.removeValueForKey(urlString)
    
        return responseURL
    }
}


class MockNetworkService : NetworkRequestService {

    func enqueueNetworkRequest(request: NetworkRequest) -> NetworkOperation? {

        let operation = MockRequestOperation(request: request.urlRequest)

        let completion = completionForRequest(request: request)

        operation.startConnection(completion: completion)

        return operation
    }

    func enqueueNetworkUploadRequest(request: NetworkUploadRequest) -> NetworkUploadOperation? {
        
        let operation = MockRequestOperation(request: request.urlRequest)
        
        let completion = completionForRequest(request: request)
        
        operation.startConnection(completion: completion)
        
        return operation

    }
    
    func enqueueNetworkDownloadRequest(request: NetworkDownloadRequest) -> NetworkDownloadOperation? {
        
        return nil
    }

    func cancelAllOperations() {

    }
}

struct MockRequestOperation: NetworkUploadOperation {
    
    let request: URLRequest
    
    init(request: URLRequest) {
        self.request = request
    }
    
    func startConnection(completion: DataResponseCompletion) {

        guard let urlString = request.url?.absoluteString else {
           debugPrint("No url given for loading mock request")
            return
        }

       debugPrint("Requesting url: \(urlString)")
        
        guard let fileURL = MockRequestQueue.dequeueResponeFileForRequestURL(urlString: urlString) else {

           debugPrint("File url not found: \(urlString)")

            let error = NSError(domain: "Network", code: 101, userInfo: nil)

            completion(nil, error)
            return
        }

        if let url = URL(string: fileURL) {
        
           debugPrint("Loading file url for request: \(String(describing: urlString)) \n")

            let data = try? Data (contentsOf: url)
            
            completion(data, nil)
            
        } else {
            
           debugPrint("File url for request not found\n")

            let error = NSError(domain: "Network", code: 101, userInfo: nil)
            
            completion(nil, error)
        }
    }
    
    func cancel() {
        
        
    }
    
    func pause() {
        
    }
    
    func resume() {
        
    }
    
    func registerProgressUpdate(progressUpdate: @escaping ProgressUpdate) {
        
    }
}
