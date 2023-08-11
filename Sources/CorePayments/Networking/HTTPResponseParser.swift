import Foundation

/// :nodoc:
public class HTTPResponseParser {
    
    private let decoder: JSONDecoder

    public init(decoder: JSONDecoder = JSONDecoder()) { // exposed for test injection
        self.decoder = decoder
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    public func parse<T: Decodable>(_ httpResponse: HTTPResponse, as type: T.Type) throws -> T {
        guard let data = httpResponse.body else {
            throw APIClientError.noResponseDataError
        }
        
        if httpResponse.isSuccessful {
            do {
                let decodedData = try decoder.decode(T.self, from: data)
                return (decodedData)
            } catch {
                throw APIClientError.jsonDecodingError(error.localizedDescription)
            }
        } else {
            do {
                let errorData = try decoder.decode(GraphQLErrorResponse.self, from: data)
                throw APIClientError.serverResponseError(errorData.error)

//                throw APIClientError.serverResponseError(errorData.readableDescription)
            } catch {
                throw APIClientError.jsonDecodingError(error.localizedDescription)
            }
        }
    }
}

struct GraphQLErrorResponse: Decodable {
    
    let error: String
    let correlationId: String?
}
