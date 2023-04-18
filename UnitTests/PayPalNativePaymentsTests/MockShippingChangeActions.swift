@testable import PayPalNativePayments

class MockShippingChangeActions: ShippingActionsProtocol {
    
    var rejectInvoked = false
    var approveInvoked = false
    
    func reject() {
        rejectInvoked = true
    }
    
    func approve() {
        approveInvoked = true
    }
    
}
