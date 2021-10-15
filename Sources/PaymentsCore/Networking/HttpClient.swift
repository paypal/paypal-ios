
import UIKit

class HttpClient: Http {
    
    // MARK: - Constants
    
    // TODO: come up with fine grained list of error codes
    static let STATUS_UNDETERMINED = -1
    
    // MARK: - Properties
    private let urlSession: URLSession
    
    // MARK: - Initializers
    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    // MARK: - Http
    func send(_ urlRequest: URLRequest, completion: @escaping (HttpResponse) -> Void) {
        let task = urlSession.dataTask(with: urlRequest) { data, response, error in
            var status: Int!
            var headers: [AnyHashable: Any] = [:]
            if let httpResponse = response as? HTTPURLResponse {
                status = httpResponse.statusCode
                headers = httpResponse.allHeaderFields
            } else {
                status = Self.STATUS_UNDETERMINED
            }
            completion(HttpResponse(status: status, headers: headers, body: data, error: error))
        }
        task.resume()
    }
}
