import Foundation

// TODO: Align with Android on this
// TODO: Adding paymentSource field?
public struct OrderData {

    public let orderID: String
    public let status: OrderStatus?

    public init(orderID: String, status: OrderStatus?) {
        self.orderID = orderID
        self.status = status
    }
}
