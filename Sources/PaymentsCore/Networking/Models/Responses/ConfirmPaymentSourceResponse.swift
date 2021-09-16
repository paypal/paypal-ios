import Foundation

public struct ConfirmPaymentSourceResponse: Codable {
    var id: String
    var status: String

    enum CodingKeys: String, CodingKey {
        case id
        case status
    }
}

