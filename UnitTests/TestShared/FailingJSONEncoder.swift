import Foundation

enum TestError: Error {
    case encodeError
}

class FailingJSONEncoder: JSONEncoder {
    
    override func encode<T>(_ value: T) throws -> Data where T: Encodable {
        throw TestError.encodeError
    }
}
