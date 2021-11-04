//
//  PayPalCreateOrder.swift
//  PayPal
//
//  Created by Jones, Jon on 11/4/21.
//

import Foundation
@_implementationOnly import PayPalCheckout

protocol PayPalCreateOrder {
    func set(orderId: String)
}

extension CreateOrderAction: PayPalCreateOrder { }
