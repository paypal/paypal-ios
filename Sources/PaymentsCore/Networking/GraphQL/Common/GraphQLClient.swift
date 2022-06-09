import Foundation
import PaymentsCore

class GraphQLClient {

    private let environment: Environment
    private let urlSession: URLSession
    private let jsonDecoder = JSONDecoder()

    public init(environment: Environment) {
        self.environment = environment
        self.urlSession = URLSession.shared
    }

    func executeQuery<T: Decodable>(query: GraphQLQuery) async throws -> GraphQLQueryResponse<T> {
        var request = try createURLRequest(requestBody: query.requestBody())
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

    func createURLRequest(requestBody: Data) throws -> URLRequest {
        var urlRequest = URLRequest(url: environment.graphqlURL)
        urlRequest.httpMethod = HTTPMethod.post.rawValue
        urlRequest.httpBody = requestBody
        return urlRequest
    }

    func headers() -> [String: String] {
        return [
            "Content-type": "application/json",
            "Accept": "application/json",
            "x-app-name": "northstar",
            "Origin": environment.graphqlURL.absoluteString
        ]
    }
}

extension GraphQLQuery {

    func requestBody() throws -> Data {
        let body: [String: Any] = [
            "query": query,
            "variables": variables
        ]
        let data = try JSONSerialization.data(withJSONObject: body, options: [])
        return data
    }
}
