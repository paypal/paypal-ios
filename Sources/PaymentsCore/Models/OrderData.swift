import Foundation

public struct OrderData {
    let orderID: String
    let status: OrderStatus
}

public enum OrderStatus: String {
    case created = "CREATED"
    case approved = "APPROVED"
    case completed = "COMPLETED"
}
