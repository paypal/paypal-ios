import UIKit

final public class CacheManager {
    
    private let cache = URLCache.shared

    // Exposed for testing
    
    func getImageFromCache(request: URLRequest, completion: (Result<CachedURLResponse, Error>) -> Void) {
        if let result = self.cache.cachedResponse(for: request) {
            completion(.success(result))
        } else {
            completion(.failure(CoreSDKError(code: 1, domain: "", errorDescription: "")))
        }
    }
    
    func putRequestInCache(request: URLRequest, response: CachedURLResponse) {
        // let cachedData = CachedURLResponse(response: chacheableImage.response, data: chacheableImage.data)
        self.cache.storeCachedResponse(response, for: request)
    }
    
}
