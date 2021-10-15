
import UIKit

public class APIClient2: API {
    
    private let http: Http
    private let config: CoreConfig
    
    private let decoder = JSONDecoder()
    
    public convenience init(config: CoreConfig) {
        self.init(config: config, http: HttpClient())
    }
    
    init(config: CoreConfig, http: Http) {
        self.http = http
        self.config = config
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    public func send(_ apiRequest: APIRequest2, completion: @escaping (HttpResponse) -> Void) {
        if let urlRequest = urlRequest(from: apiRequest) {
            http.send(urlRequest, completion: completion)
        } else {
            // TODO: handle error
        }
    }
    
    private func urlRequest(from apiRequest: APIRequest2) -> URLRequest? {
        let completeUrl = config.environment.baseURL.appendingPathComponent(apiRequest.path)
        let urlComponents = URLComponents(url: completeUrl, resolvingAgainstBaseURL: false)

        guard let url = urlComponents?.url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = apiRequest.method.rawValue
        request.httpBody = apiRequest.body?.encoded()
        
        // TODO: Remove clientSecret when this endpoint is updated and can be used with low-scoped token
        // For now, include your clientSecret here and your clientID in CoreConfig to test this request
        let clientSecret = ""
        let encodedClientID = "\(config.clientID):\(clientSecret)".data(using: .utf8)?.base64EncodedString() ?? ""

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("en_US", forHTTPHeaderField: "Accept-Language")
        request.addValue("Basic \(encodedClientID)", forHTTPHeaderField: "Authorization")

        return request
    }
}
