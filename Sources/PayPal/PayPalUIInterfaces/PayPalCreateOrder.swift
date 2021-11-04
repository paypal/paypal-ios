import Foundation
@_implementationOnly import PayPalCheckout

protocol PayPalCreateOrder {
    func set(orderId: String)
}

extension CreateOrderAction: PayPalCreateOrder { }
