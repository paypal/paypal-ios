import Foundation

protocol URLCacheable {
    
    func cachedResponse(for request: URLRequest) -> CachedURLResponse?
    func storeCachedResponse(_ cachedResponse: CachedURLResponse, for request: URLRequest)
}

extension URLCache: URLCacheable { }
