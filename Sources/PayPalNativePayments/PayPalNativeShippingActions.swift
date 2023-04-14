import PayPalCheckout

public class PayPalNativeShippingActions {

    private let shippingActions: ShippingChangeAction
    
    init(_ shippingActions: ShippingChangeAction) {
        self.shippingActions = shippingActions
    }
    
    public func reject() { self.shippingActions.reject() }
    
    public func approve() { self.shippingActions.approve() }
}
