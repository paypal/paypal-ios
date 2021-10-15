
import UIKit

class HTTPClient: HTTP {
    
    // MARK: - Constants
    
    // TODO: come up with fine grained list of error codes
    static let STATUS_UNDETERMINED = -1
    
    // MARK: - Properties
    private let urlSession: URLSessionProtocol
    
    // MARK: - Initializers
    public init(urlSession: URLSessionProtocol = URLSession.shared) {
        self.urlSession = urlSession
    }

    // MARK: - HTTP
    func send(_ urlRequest: URLRequest, completion: @escaping (HTTPResponse) -> Void) {
        urlSession.performRequest(with: urlRequest) { data, response, error in
            var status: Int!
            var headers: [AnyHashable: Any] = [:]
            if let httpResponse = response as? HTTPURLResponse {
                status = httpResponse.statusCode
                headers = httpResponse.allHeaderFields
            } else {
                status = Self.STATUS_UNDETERMINED
            }
            completion(HTTPResponse(status: status, headers: headers, body: data, error: error))
        }
    }
}
