import Foundation
import PayPalCheckout

protocol PayPalCreateOrder {
    func set(orderId: String)
}

extension CreateOrderAction: PayPalCreateOrder { }
