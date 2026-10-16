import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

/// JSON value used to forward the Apple Pay payment data object without reshaping it.
enum JSONValue: Codable {

    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case object([String: JSONValue])
    case array([JSONValue])
    case null

    init(json: Any) throws {
        if json is NSNull {
            self = .null
            return
        }
        if let value = json as? String {
            self = .string(value)
            return
        }
        if let value = json as? [String: Any] {
            var object: [String: JSONValue] = [:]
            for (key, item) in value {
                object[key] = try JSONValue(json: item)
            }
            self = .object(object)
            return
        }
        if let value = json as? [Any] {
            self = .array(try value.map { try JSONValue(json: $0) })
            return
        }
        if let number = json as? NSNumber {
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                self = .bool(number.boolValue)
            } else if CFNumberIsFloatType(number) {
                self = .double(number.doubleValue)
            } else {
                self = .int(number.intValue)
            }
            return
        }
        throw ApplePayError.invalidToken
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .object(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode([String: JSONValue].self) {
            self = .object(value)
        } else if let value = try? container.decode([JSONValue].self) {
            self = .array(value)
        } else {
            throw ApplePayError.invalidToken
        }
    }
}
