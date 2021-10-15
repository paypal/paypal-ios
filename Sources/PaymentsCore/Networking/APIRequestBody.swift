import UIKit

public protocol APIRequestBody: Encodable {
    func encoded() -> Data?
}

extension APIRequestBody {

    public func encoded() -> Data? {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return try? encoder.encode(self)
    }
}
