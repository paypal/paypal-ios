//
//  PayPalApproval.swift
//  PayPalApproval
//
//  Created by Jones, Jon on 11/4/21.
//

import Foundation
import PayPalCheckout

protocol PayPalCheckoutApproval {
    associatedtype ApprovalDataType: PayPalCheckoutApprovalData
    var data: ApprovalDataType { get }
}

protocol PayPalCheckoutApprovalData {
    var intent: String { get }
    var payerID: String { get }
    var ecToken: String { get }
}

extension Approval: PayPalCheckoutApproval { }
extension ApprovalData: PayPalCheckoutApprovalData { }
