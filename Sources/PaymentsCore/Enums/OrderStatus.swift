import Foundation

/// The status of an order
public enum OrderStatus: String, Codable {
    /// The order was created
    case created = "CREATED"

    /// The order was approved with a valid payment source
    case approved = "APPROVED"

    /// The order is completed and paid
    case completed = "COMPLETED"
}
