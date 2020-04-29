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
    
    public class func builder(withHost: String, path: String) -> URLRequestBuilder {
        return URLRequestBuilderImpl(host: withHost, path: path)
    }
    
    public class func builder(with url: URL) -> URLRequestBuilder {
        return URLRequestBuilderImpl(url: url)
    }
    
    public class func builder(with urlString: String) -> URLRequestBuilder {
        return URLRequestBuilderImpl(urlString: urlString)
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
        
        private var urlComponents: URLComponents?
        private var requestMethod: HTTPMethod = .get
        private var requestHeaders: [String: String]? = nil
        private var encoder: URLRequestEncoder = DoNothingEncoder()
        
        init(url: URL) {
            urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        }
        
        init(host: String, path: String) {
            urlComponents = URLComponents()
            urlComponents?.host = host
            urlComponents?.path = path
        }
        
        init(urlString: String) {
            urlComponents = URLComponents(string: urlString)
        }
        
        func set(scheme: String) -> URLRequestBuilder {
            self.urlComponents?.scheme = scheme
            return self
        }
        
        func set(host: String) -> URLRequestBuilder {
            self.urlComponents?.host = host
            return self
        }
        
        func set(query: String, value: String?) -> URLRequestBuilder {
            var queryItems = self.urlComponents?.queryItems ?? [URLQueryItem]()
            queryItems.append(URLQueryItem(name: query, value: value))
            self.urlComponents?.queryItems = queryItems
            return self
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
            
            guard let components = urlComponents else { throw URLRequestBuilderError.invalidURL }
            
            var url = try components.asURL()
            
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
