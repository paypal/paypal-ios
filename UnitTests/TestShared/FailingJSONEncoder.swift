import Foundation
@testable import CorePayments

enum TestError: Error {
    case encodeError
}

class FailingJSONEncoder: JSONEncoder {
    
    override func encode<T>(_ value: T) throws -> Data where T: Encodable {
        throw TestError.encodeError
    }
}

class FailingJSONDecoder: JSONDecoder {
    
    override func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        throw CoreSDKError(
            code: 1,
            domain: "JSONDecoder.FakeDomain",
            errorDescription: "Stub message from JSONDecoder."
        )
    }
}
