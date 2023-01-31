import Foundation
@testable import PaymentsCore

class MockURLCache: URLCacheTestable {
    
    var cannedCachedURLResponse: CachedURLResponse?
    var cannedCache: [URLRequest: CachedURLResponse] = [:]
    
    func storeCachedResponse(_ cachedResponse: CachedURLResponse, for request: URLRequest) {
        cannedCache[request] = cachedResponse
    }
    
    func cachedResponse(for request: URLRequest) -> CachedURLResponse? {
        return cannedCache[request]
    }
}
