import XCTest
@testable import PayPalNativePayments

class PayPalNativePaysheetAction_Tests: XCTestCase {

    func testReject_whenRejectIsCalled_wrappedRejectIsInvoked() {
        let mockWrappedShippingActions = MockShippingChangeActions()
        let payPalNativeShippingActions = PayPalNativePaysheetActions(mockWrappedShippingActions)
        
        payPalNativeShippingActions.reject()
        XCTAssertTrue(mockWrappedShippingActions.rejectInvoked)
    }
    
    func testApprove_whenApproveIsCalled_wrappedApproveIsInvoked() {
        let mockWrappedShippingActions = MockShippingChangeActions()
        let payPalNativeShippingActions = PayPalNativePaysheetActions(mockWrappedShippingActions)
        
        payPalNativeShippingActions.approve()
        XCTAssertTrue(mockWrappedShippingActions.approveInvoked)
    }
}
