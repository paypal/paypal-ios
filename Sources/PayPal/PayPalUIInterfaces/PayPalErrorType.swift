//
//  PayPalError.swift
//  PayPalError
//
//  Created by Jones, Jon on 11/4/21.
//

import Foundation
@_implementationOnly import PayPalCheckout

protocol PayPalCheckoutErrorInfo {
    var reason: String { get }
    var error: Error { get }
}

extension ErrorInfo: PayPalCheckoutErrorInfo { }
