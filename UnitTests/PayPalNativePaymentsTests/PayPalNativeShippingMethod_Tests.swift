import XCTest
import PayPalCheckout
@testable import PayPalNativePayments

class PayPalNativeShippingMethod_Tests: XCTestCase {

    func testInit_convertsFromNXOTypeCorrectly() {
        let nxoUnitAmount = PayPalCheckout.UnitAmount(
            currencyCode: CurrencyCode.usd,
            value: "10.00"
        )
        let nxoShippingMethod = PayPalCheckout.ShippingMethod(
            id: "fake-id",
            label: "fake-label",
            selected: true,
            type: PayPalCheckout.ShippingType.pickup,
            amount: nxoUnitAmount)
        
        let sut = PayPalNativeShippingMethod(nxoShippingMethod)
        XCTAssertEqual(sut.id, "fake-id")
        XCTAssertEqual(sut.label, "fake-label")
        XCTAssertTrue(sut.selected)
        XCTAssertEqual(sut.type, PayPalNativeShippingMethod.DeliveryType.pickup)
        XCTAssertEqual(sut.value, "10.00")
        XCTAssertEqual(sut.currencyCode, "USD")
    }
}
