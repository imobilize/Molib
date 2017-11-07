import Foundation

public enum HTTPMethod : String {

    case options

    case get

    case head

    case post

    case put

    case patch

    case delete

    case trace

    case connect
}

public protocol URLRequestBuilder {
    init(url: URL)

    func asURLRequest() -> URLRequest

    func setEncoder(encoder: URLRequestEncoder) -> URLRequestBuilder

    func setRequestMethod(method: HTTPMethod) -> URLRequestBuilder

    func setHeaders(headers: [String: String]) -> URLRequestBuilder
}

public class URLRequestBuilderFactory {
    class func builder(with url: URL) -> URLRequestBuilder {
        return URLRequestBuilderImpl(url: url)
    }
}

class URLRequestBuilderImpl: URLRequestBuilder {

    let url: URL
    var requestMethod: HTTPMethod = .get
    var requestHeaders: [String: String]? = nil
    var encoder: URLRequestEncoder = DoNothingEncoder()

    required init(url: URL) {
        self.url = url
    }

    func setEncoder(encoder: URLRequestEncoder) -> URLRequestBuilder {
        self.encoder = encoder
        return self
    }

    func setRequestMethod(method: HTTPMethod) -> URLRequestBuilder {
        self.requestMethod = method
        return self
    }

    func setHeaders(headers: [String: String]) -> URLRequestBuilder {
        self.requestHeaders = headers
        return self
    }

    func asURLRequest() -> URLRequest {

        var request = URLRequest(url: url)

        request.httpMethod = requestMethod.rawValue

        request = addHeaders(to: request)

        do {
            try request = encoder.encodeRequest(request: request)
        } catch {}

        return request
    }

    private func addHeaders(to request: URLRequest) -> URLRequest {

        var updatedRequest = request
        if let headers = requestHeaders {
            for (key, headerValue) in headers {
                updatedRequest.addValue(headerValue, forHTTPHeaderField: key)
            }
        }

        return updatedRequest
    }
}


extension URLRequest {
    init?(string: String) {
        if let url = URL(string: string) {
            self.init(url: url)
        } else {
            return nil
        }
    }
}
