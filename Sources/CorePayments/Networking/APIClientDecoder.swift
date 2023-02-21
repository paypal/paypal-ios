import Foundation

class APIClientDecoder {

    private let decoder: JSONDecoder

    init() {
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func decode<T: APIRequest>(_ type: T.Type, from data: Data) throws -> T.ResponseType {
        guard !data.isEmpty else {
            if let emptyResponse = EmptyResponse() as? T.ResponseType {
                return emptyResponse
            } else {
                throw APIClientError.noResponseDataError
            }
        }
        
        do {
            return try self.decoder.decode(T.ResponseType.self, from: data)
        } catch {
            throw APIClientError.dataParsingError
        }
    }

    func decode(from data: Data) throws -> ErrorResponse {
        do {
            return try self.decoder.decode(ErrorResponse.self, from: data)
        } catch {
            throw APIClientError.unknownError
        }
    }
}
