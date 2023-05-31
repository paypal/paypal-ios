import Foundation

/// `HTTP` interfaces directly with `URLSession` to execute network requests.
class HTTP {
    
    let coreConfig: CoreConfig
    private var urlSession: URLSessionProtocol
    private let decoder = APIClientDecoder()

    init(
        urlSession: URLSessionProtocol = URLSession.shared,
        coreConfig: CoreConfig
    ) {
        self.urlSession = urlSession
        self.coreConfig = coreConfig
    }
    
    func performRequest<T: APIRequest>(_ request: T) async throws -> (T.ResponseType) {
        guard let urlRequest = request.toURLRequest(environment: coreConfig.environment) else {
            throw APIClientError.invalidURLRequestError
        }
        
        let (data, response) = try await urlSession.performRequest(with: urlRequest)
        guard let response = response as? HTTPURLResponse else {
            throw APIClientError.invalidURLResponseError
        }
        
        switch response.statusCode {
        case 200..<300:
            let decodedData = try decoder.decode(T.self, from: data)
            return (decodedData)
        default:
            let errorData = try decoder.decode(from: data)
            throw APIClientError.serverResponseError(errorData.readableDescription)
        }
    }
}
