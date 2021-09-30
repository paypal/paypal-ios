import Foundation

public struct OrderData {
    public let orderID: String
    public let status: OrderStatus?

    public init(orderID: String, status: OrderStatus?) {
        self.orderID = orderID
        self.status = status
    }
}
