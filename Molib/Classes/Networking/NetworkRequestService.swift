import Foundation


public typealias DownloadCompletion = (_ downloadModel: MODownloadModel, _ errorOptional: Error?) -> Void

public typealias DownloadLocation = (_ downloadModel: MODownloadModel, _ donwloadFileTemporaryLocation: URL) -> URL
public typealias DownloadLocationCompletion = (_ fileLocation: URL) -> URL

public typealias DownloadOperationCompletion = (_ request: NetworkDownloadRequest) -> NetworkDownloadOperation?
public typealias DownloadProgressUpdator = (_ bytesRead: Int64, _ totalBytesRead: Int64, _ totalBytesExpectedToRead: Int64) -> Void
public typealias DownloadProgressCompletion = (_ downloadModel: MODownloadModel) -> Void

public typealias JSONResponseCompletion = (_ responseOptional: AnyObject?, _ errorOptional: Error?) -> Void
public typealias ProgressUpdate = (_ progress: Float) -> Void


public protocol AuthenticatableRequest {
    
    func allowAuthentication() -> Bool
}

public protocol NetworkRequest {

    var urlRequest: URLRequest { get }

    func handleResponse(dataOptional: Data?, errorOptional: Error?)
}

public protocol NetworkUploadRequest: NetworkRequest {

    var name: String { get }
    
    var fileName: String { get }

    var mimeType: String { get }

    var fileURL: URL { get }
}

public protocol NetworkDownloadRequest: NetworkRequest {

    var fileName: String { get }

    var downloadLocationURL: URL { get }
}

public protocol NetworkOperation {

    func cancel()
}

public protocol NetworkUploadOperation: NetworkOperation {

    func pause()

    func resume()

    func registerProgressUpdate(progressUpdate: @escaping ProgressUpdate)
}

public protocol NetworkDownloadOperation: NetworkOperation {

    func pause()

    func resume()

    func registerProgressUpdate(progressUpdate: @escaping ProgressUpdate)
}

public protocol NetworkRequestService {

    @discardableResult func enqueueNetworkRequest(request: NetworkRequest) -> NetworkOperation?

    @discardableResult func enqueueNetworkUploadRequest(request: NetworkUploadRequest) -> NetworkUploadOperation?

    @discardableResult func enqueueNetworkDownloadRequest(request: NetworkDownloadRequest) -> NetworkDownloadOperation?

    func cancelAllOperations()
}

extension NetworkRequestService {

    func completionForRequest(request: NetworkRequest) -> DataResponseCompletion {

        let completion = { (dataOptional: Data?, errorOptional: Error?) -> Void in

            if dataOptional == nil && errorOptional == nil {

                let userInfo = [NSLocalizedDescriptionKey: "Invalid response"]

                let error = NSError(domain: "NetworkService", code: 101, userInfo: userInfo)

                request.handleResponse(dataOptional: dataOptional, errorOptional: error)

            } else {

                request.handleResponse(dataOptional: dataOptional, errorOptional: errorOptional)
            }
        }

        return completion
    }

    func completionForDownloadRequest(request: NetworkDownloadRequest) -> ErrorCompletion {

        let completion = { (errorOptional: Error?) in

            var error: Error?

            if errorOptional != nil {

                let userInfo = [NSLocalizedDescriptionKey: "Invalid response"]

                error = NSError(domain: "NetworkService", code: 101, userInfo: userInfo)
            }

            request.handleResponse(dataOptional: nil, errorOptional: error)

        }

        return completion
    }
}
