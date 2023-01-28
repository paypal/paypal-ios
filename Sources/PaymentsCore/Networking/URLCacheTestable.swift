import Foundation

protocol URLCacheTestable {
    
    func cachedResponse(for request: URLRequest) -> CachedURLResponse?
    
    func storeCachedResponse(_ cachedResponse: CachedURLResponse, for request: URLRequest)
}

extension URLCache: URLCacheTestable { }
