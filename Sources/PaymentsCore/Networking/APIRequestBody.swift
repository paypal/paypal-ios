
import UIKit

fileprivate let encoder = JSONEncoder()

public protocol APIRequestBody: Encodable {
    func encoded() -> Data?
}

extension APIRequestBody {
    
    public func encoded() -> Data? {
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return try? encoder.encode(self)
    }
}
