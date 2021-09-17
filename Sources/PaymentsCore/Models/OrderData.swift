import Foundation

public struct OrderData {
    let orderID: String
    let status: OrderStatus?
}

/// The status of an order
public enum OrderStatus: String {
    /// The order was created
    case created = "CREATED"

    /// The order was approved by buyer with a valid payment source
    case approved = "APPROVED"

    /// The order is completed and paid
    case completed = "COMPLETED"
}
