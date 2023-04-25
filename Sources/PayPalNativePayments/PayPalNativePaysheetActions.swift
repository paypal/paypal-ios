import PayPalCheckout

/// The actions that can be used to update the Paysheet UI after `PayPalNativeShippingDelegate` methods are invoked.
public class PayPalNativePaysheetActions {

    private let shippingActions: ShippingActionsProtocol
    
    init(_ shippingActions: ShippingActionsProtocol) {
        self.shippingActions = shippingActions
    }
    
    /// Call reject when a buyer selects a shipping option that is not supported or has entered a shipping address that is not supported.
    /// The paysheet will require the buyer to fix the issue before continuing with the order.
    /// Remove the error message by calling approve
    public func reject() { self.shippingActions.reject() }
    
    
    /// Will refresh the paysheet with the latest updates to the current order. Call `approve` when:
    ///  - A buyer selects a shipping address that is supported. Removes the error message on the
    ///    paysheet displayed after calling `reject`.
    ///  - After an order has been successfully patched on your server (e.g, update amount after new shipping method
    ///    has been selected), to see the changes reflected on paysheet.
    /// For more information on patching an order, visit: https://developer.paypal.com/docs/api/orders/v2/#orders_patch
    public func approve() { self.shippingActions.approve() }
}

protocol ShippingActionsProtocol {
    
    func reject()
    func approve()
}

extension ShippingChangeAction: ShippingActionsProtocol { }
