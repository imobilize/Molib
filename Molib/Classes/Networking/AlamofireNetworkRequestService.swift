import Foundation
import Alamofire

class AlamofireNetworkRequestService: NetworkRequestService {

    init() {
    }

    func enqueueNetworkRequest(request: NetworkRequest) -> NetworkOperation? {

        let alamoFireRequestOperation = AlamofireNetworkOperation(networkRequest: request)

        alamoFireRequestOperation.performRequest()

        return alamoFireRequestOperation
    }

    func enqueueNetworkUploadRequest(request: NetworkUploadRequest) -> NetworkUploadOperation? {

        let alamorFireUploadOperation = AlamofireNetworkUploadOperation(networkRequest: request)

        alamorFireUploadOperation.performRequest()

        return alamorFireUploadOperation
    }

    func enqueueNetworkDownloadRequest(request: NetworkDownloadRequest) -> NetworkDownloadOperation? {

        let alamorFireDownloadOperation = AlamofireNetworkDownloadOperation(networkRequest: request)

        alamorFireDownloadOperation.performRequest()

        return alamorFireDownloadOperation
    }

    func cancelAllOperations() {
        AF.cancelAllRequests()
    }
}

class AlamofireNetworkOperation: NetworkOperation {

    private let networkRequest: NetworkRequest
    private var alamoFireRequest: DataRequest?

    init(networkRequest: NetworkRequest) {
        self.networkRequest = networkRequest
    }

    func performRequest() {

        alamoFireRequest = AF.request(networkRequest.urlRequest)
        alamoFireRequest?.validate().responseData { [weak self](networkResponse) -> Void in

            debugPrint("Request response for URL: \(String(describing: self?.networkRequest.urlRequest.url))")

            self?.networkRequest.handleResponse(dataOptional: networkResponse.data, errorOptional: networkResponse.error)
        }
    }

    func cancel() {

        alamoFireRequest?.cancel()
    }
}


class AlamofireNetworkUploadOperation : NetworkUploadOperation {

    private let networkRequest: NetworkUploadRequest
    private var alamoFireRequest: UploadRequest?

    init(networkRequest: NetworkUploadRequest) {
        self.networkRequest = networkRequest
    }

    func performRequest() {

        alamoFireRequest = AF.upload(networkRequest.fileURL, with: networkRequest.urlRequest)
        
        alamoFireRequest?.validate().responseData { [weak self](networkResponse) -> Void in

            debugPrint("Download request response for URL: \(String(describing: self?.networkRequest.urlRequest.url))")

            self?.networkRequest.handleResponse(dataOptional: networkResponse.data, errorOptional: networkResponse.error)
        }
    }

    func registerProgressUpdate(progressUpdate: @escaping ProgressUpdate) {

        alamoFireRequest?.downloadProgress(closure: { (progress: Progress) in

            var downloadProgress: Float = 0

            if let fileTotal = progress.fileTotalCount, let fileCompleted = progress.fileCompletedCount {
                    downloadProgress = Float(fileTotal)/Float(fileCompleted)
            }

            progressUpdate(downloadProgress)
        })
    }

    func pause() {
        alamoFireRequest?.suspend()
    }

    func resume() {
        alamoFireRequest?.resume()
    }

    func cancel() {
        alamoFireRequest?.cancel()
    }
}

class AlamofireNetworkDownloadOperation: NetworkDownloadOperation {

    private let networkRequest: NetworkDownloadRequest
    private var alamoFireRequest: DownloadRequest?

    init(networkRequest: NetworkDownloadRequest) {
        self.networkRequest = networkRequest
    }

    func performRequest() {

        alamoFireRequest = AF.download(networkRequest.urlRequest, to: { (url, response) -> (destinationURL: URL, options: DownloadRequest.Options) in

            return (self.networkRequest.downloadLocationURL, Alamofire.DownloadRequest.Options.removePreviousFile)
        })

        alamoFireRequest?.validate().responseData { [weak self](networkResponse) -> Void in

            debugPrint("Request response for URL: \(String(describing: self?.networkRequest.urlRequest.url))")

            self?.networkRequest.handleResponse(dataOptional: networkResponse.value, errorOptional: networkResponse.error)
        }
    }

    func registerProgressUpdate(progressUpdate: @escaping ProgressUpdate) {

        alamoFireRequest?.downloadProgress(closure: { (progress: Progress) in

            var downloadProgress: Float = 0

            if let fileTotal = progress.fileTotalCount, let fileCompleted = progress.fileCompletedCount {
                downloadProgress = Float(fileTotal)/Float(fileCompleted)
            }

            progressUpdate(downloadProgress)
        })
    }

    func pause() {
        alamoFireRequest?.suspend()
    }

    func resume() {
        alamoFireRequest?.resume()
    }

    func cancel() {
        alamoFireRequest?.cancel()
    }
}


extension NetworkDownloadOperation {

    func handleResponse<T>(networkResponse: AFDataResponse<T>, completion: DataResponseCompletion) {

        debugPrint(networkResponse)

        var errorOptional: Error? = nil

        switch networkResponse.result {

        case .success: break


        case .failure(let error):

            if let response = networkResponse.response {

                let errorMessage = NSLocalizedString("The service is currently unable to satisfy your request. Please try again later", comment: "Bad service response text")

                let userInfo: [String: Any] = ["response": response, NSUnderlyingErrorKey: error]

                errorOptional = NSError(domain: "RequestOperation", code: response.statusCode, userInfo: userInfo)

            } else {

                let errorMessage = NSLocalizedString("The service is currently unavailable. Please try again later", comment: "Service unavailable text")

                let userInfo: [String: Any] = [NSUnderlyingErrorKey: error, NSLocalizedDescriptionKey: errorMessage]

                errorOptional = NSError(domain: "RequestOperation", code: 101, userInfo: userInfo)
            }
        }

        completion(networkResponse.data, errorOptional)

    }
}
