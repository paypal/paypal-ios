import Foundation

@_documentation(visibility: private)
public class HTTPResponseParser {
    
    private let decoder: JSONDecoder
    
    // MARK: - Initializer

    public init(decoder: JSONDecoder = JSONDecoder()) { // exposed for test injection
        self.decoder = decoder
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    // MARK: - Public Methods

    public func parseREST<T: Decodable>(_ httpResponse: HTTPResponse, as type: T.Type) throws -> T {
        guard let data = httpResponse.body else {
            throw NetworkingError.noResponseDataError
        }
        
        if httpResponse.isSuccessful {
            return try parseSuccessResult(data, as: T.self)
        } else {
            return try parseErrorResult(data, as: T.self)
        }
    }
    
    public func parseGraphQL<T: Decodable>(_ httpResponse: HTTPResponse, as type: T.Type) throws -> T {
        guard let data = httpResponse.body else {
            throw NetworkingError.noResponseDataError
        }
        
        if httpResponse.isSuccessful {
            return try parseSuccessResult(data, as: T.self, isGraphQL: true)
        } else {
            return try parseErrorResult(data, as: T.self, isGraphQL: true)
        }
    }
    
    // MARK: - Private Methods
    
    private func parseSuccessResult<T: Decodable>(_ data: Data, as type: T.Type, isGraphQL: Bool = false) throws -> T {
        do {
            if isGraphQL {
                guard let data = try decoder.decode(GraphQLHTTPResponse<T>.self, from: data).data else {
                    throw NetworkingError.noGraphQLDataKey
                }
                return data
            } else {
                return try decoder.decode(T.self, from: data)
            }
        } catch {
            Self.logDecodingFailure(type: T.self, isGraphQL: isGraphQL, data: data, error: error)
            throw NetworkingError.jsonDecodingError(error.localizedDescription)
        }
    }
    
    private func parseErrorResult<T: Decodable>(_ data: Data, as type: T.Type, isGraphQL: Bool = false) throws -> T {
        do {
            if isGraphQL {
                let errorData = try decoder.decode(GraphQLErrorResponse.self, from: data)
                throw NetworkingError.serverResponseError(errorData.error)
            } else {
                let errorData = try decoder.decode(ErrorResponse.self, from: data)
                throw NetworkingError.serverResponseError(errorData.readableDescription)
            }
        } catch {
            Self.logDecodingFailure(type: T.self, isGraphQL: isGraphQL, data: data, error: error)
            throw NetworkingError.jsonDecodingError(error.localizedDescription)
        }
    }

    #if DEBUG
    private static func logDecodingFailure<T>(type: T.Type, isGraphQL: Bool, data: Data, error: Error) {
        let body = String(data: data, encoding: .utf8) ?? "<\(data.count) bytes, non-UTF8>"
        print(
            """
            📡 [PayPal SDK] 🔴 DECODE FAILED
            Expecting: \(isGraphQL ? "GraphQL<\(T.self)>" : "\(T.self)")
            Error: \(error)
            Raw body: \(body)
            """
        )
    }
    #endif
}

extension HTTPResponseParser {

    // to extract correlationId from GraphQL response
    @_documentation(visibility: private)
    public func parseGraphQLDictionary(_ httpResponse: HTTPResponse) throws -> [String: Any] {

        guard httpResponse.status == 200 else {
            throw NetworkingError.urlSessionError
        }

        guard let body = httpResponse.body else {
            throw NetworkingError.noResponseDataError
        }

        let jsonObject = try JSONSerialization.jsonObject(with: body, options: [])
        guard let topLevel = jsonObject as? [String: Any] else {
            throw NetworkingError.invalidURLResponseError
        }

        return topLevel
    }
}
