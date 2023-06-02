import Foundation

class HTTPResponseParser {
    
    private let decoder: JSONDecoder

    init(decoder: JSONDecoder = JSONDecoder()) { // exposed for test injection
        self.decoder = decoder
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    func parse<T: Decodable>(_ httpResponse: HTTPResponse, as type: T.Type) throws -> T {
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
                let errorData = try decoder.decode(ErrorResponse.self, from: data)
                throw APIClientError.serverResponseError(errorData.readableDescription)
            } catch {
                throw APIClientError.jsonDecodingError(error.localizedDescription)
            }
        }
    }
}
