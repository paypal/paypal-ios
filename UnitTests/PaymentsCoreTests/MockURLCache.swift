import Foundation
@testable import CorePayments

class MockURLCache: URLCacheable {
    
    var cannedCachedURLResponse: CachedURLResponse?
    var cannedCache: [URLRequest: CachedURLResponse] = [:]
    
    func storeCachedResponse(_ cachedResponse: CachedURLResponse, for request: URLRequest) {
        cannedCache[request] = cachedResponse
    }
    
    func cachedResponse(for request: URLRequest) -> CachedURLResponse? {
        return cannedCache[request]
    }
}
