import Foundation

public struct ConfirmPaymentSourceResponse: Codable {
    public var id: String
    public var status: String

    enum CodingKeys: String, CodingKey {
        case id
        case status
    }
}

