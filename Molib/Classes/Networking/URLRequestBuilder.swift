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

    func asURLRequest() throws -> URLRequest

    func setEncoder(encoder: URLRequestEncoder) -> URLRequestBuilder

    func setRequestMethod(method: HTTPMethod) -> URLRequestBuilder

    func setHeaders(headers: [String: String]) -> URLRequestBuilder
}

public class URLRequestBuilderFactory {
    public class func builder(with url: URL) -> URLRequestBuilder {
        return URLRequestBuilderImpl(url: url)
    }

    public class func builder(with urlString: String) -> URLRequestBuilder {
        if let builder = URLRequestBuilderImpl(urlString: urlString) {
            return builder
        } else {
            return ThrowErrorBuilder()
        }
    }
}

class ThrowErrorBuilder: URLRequestBuilder {

    func asURLRequest() throws -> URLRequest {
        throw URLRequestBuilderError.invalidURL
    }

    func setEncoder(encoder: URLRequestEncoder) -> URLRequestBuilder {
        return self
    }

    func setRequestMethod(method: HTTPMethod) -> URLRequestBuilder {
        return self
    }

    func setHeaders(headers: [String : String]) -> URLRequestBuilder {
        return self
    }
}

class URLRequestBuilderImpl: URLRequestBuilder {

    private let url: URL
    private var requestMethod: HTTPMethod = .get
    private var requestHeaders: [String: String]? = nil
    private var encoder: URLRequestEncoder = DoNothingEncoder()

    init(url: URL) {
        self.url = url
    }

    init?(urlString: String) {
        if let url = URL(string: urlString) {
            self.url = url
        } else {
            return nil
        }
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

    func asURLRequest() throws -> URLRequest {

        var request = URLRequest(url: url)

        request.httpMethod = requestMethod.rawValue

        request = addHeaders(to: request)

        do {
            try request = encoder.encodeRequest(request: request)
        } catch {
            throw URLRequestBuilderError.invalidEncoding
        }

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

enum URLRequestBuilderError: Error {
    case invalidEncoding
    case invalidURL
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
