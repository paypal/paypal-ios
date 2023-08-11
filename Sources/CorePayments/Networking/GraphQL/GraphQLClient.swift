import Foundation

//// :nodoc: This class handles urlRequests for GraphQL endpoints
public class GraphQLClient {

    public let environment: Environment
    public let urlSession: URLSessionProtocol
    public let jsonDecoder = JSONDecoder()

    public init(environment: Environment, urlSession: URLSessionProtocol = URLSession.shared) {
        self.environment = environment
        self.urlSession = urlSession
    }

    public func callGraphQL<T: Decodable, Q: GraphQLQuery>(name: String, query: Q) async throws -> GraphQLQueryResponse<T> {
        
        var request = try createURLRequest(name: name, requestBody: query.requestBody())
        headers().forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        let (data, response) = try await urlSession.performRequest(with: request)
        guard response is HTTPURLResponse else {
            return GraphQLQueryResponse(data: nil)
        }
        let decoded: GraphQLQueryResponse<T> = try parse(data: data)
        return decoded
    }
    
    func parse<T: Decodable>(data: Data) throws -> T {
        return try jsonDecoder.decode(T.self, from: data)
    }

    func createURLRequest(name: String? = nil, requestBody: Data) throws -> URLRequest {
        var urlString = environment.graphQLURL.absoluteString
        if let name {
            urlString.append("?\(name)")
        }
        guard let url = URL(string: urlString) else {
            throw GraphQLError(message: "error fetching url", extensions: nil)
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HTTPMethod.post.rawValue
        urlRequest.httpBody = requestBody
        return urlRequest
    }

    func headers() -> [String: String] {
        [
            "Content-type": "application/json",
            "Accept": "application/json",
            "x-app-name": "northstar",
            "Origin": environment.graphQLURL.absoluteString
        ]
    }
}

extension GraphQLQuery where Self: Codable {

    public func requestBody() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }
}
