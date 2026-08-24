import XCTest
@testable import CorePayments
@testable import VenmoPayments

class VenmoError_Tests: XCTestCase {

    func testVenmoURLError_hasCorrectCodeAndDomain() {
        XCTAssertEqual(VenmoError.venmoURLError.code, 1)
        XCTAssertEqual(VenmoError.venmoURLError.domain, "VenmoClientErrorDomain")
        XCTAssertEqual(VenmoError.venmoURLError.errorDescription, "Error constructing URL for Venmo request.")
    }

    func testMalformedResultError_hasCorrectCodeAndDomain() {
        XCTAssertEqual(VenmoError.malformedResultError.code, 2)
        XCTAssertEqual(VenmoError.malformedResultError.domain, "VenmoClientErrorDomain")
        XCTAssertEqual(VenmoError.malformedResultError.errorDescription, "Result did not contain the expected data.")
    }

    func testCheckoutCanceledError_hasCorrectCodeAndDomain() {
        XCTAssertEqual(VenmoError.checkoutCanceledError.code, 3)
        XCTAssertEqual(VenmoError.checkoutCanceledError.domain, "VenmoClientErrorDomain")
        XCTAssertEqual(VenmoError.checkoutCanceledError.errorDescription, "Venmo checkout has been canceled by the user")
    }

    func testVenmoNotEligible_hasCorrectCodeAndDomain() {
        XCTAssertEqual(VenmoError.venmoNotEligible.code, 4)
        XCTAssertEqual(VenmoError.venmoNotEligible.domain, "VenmoClientErrorDomain")
        XCTAssertEqual(
            VenmoError.venmoNotEligible.errorDescription,
            "Venmo is not eligible as a funding source for this transaction."
        )
    }

    func testFundingEligibilityError_includesReason() {
        let error = VenmoError.fundingEligibilityError(reason: "buyer not eligible")
        XCTAssertEqual(error.code, 4)
        XCTAssertEqual(error.domain, "VenmoClientErrorDomain")
        XCTAssertEqual(error.errorDescription, "Venmo is not eligible as a funding source: buyer not eligible")
    }

    func testUnimplemented_hasCorrectCodeAndDomain() {
        XCTAssertEqual(VenmoError.unimplemented.code, 5)
        XCTAssertEqual(VenmoError.unimplemented.domain, "VenmoClientErrorDomain")
        XCTAssertEqual(VenmoError.unimplemented.errorDescription, "VenmoClient.start() is not yet implemented.")
    }

    func testIsCheckoutCanceled_returnsTrueForCanceledError() {
        XCTAssertTrue(VenmoError.isCheckoutCanceled(VenmoError.checkoutCanceledError))
    }

    func testIsCheckoutCanceled_returnsFalseForOtherVenmoError() {
        XCTAssertFalse(VenmoError.isCheckoutCanceled(VenmoError.venmoURLError))
    }

    func testIsCheckoutCanceled_returnsFalseForNonCoreSDKError() {
        let nsError = NSError(domain: "TestDomain", code: 0)
        XCTAssertFalse(VenmoError.isCheckoutCanceled(nsError))
    }

    func testIsCheckoutCanceled_returnsFalseForDifferentDomain() {
        let error = CoreSDKError(code: 3, domain: "OtherDomain", errorDescription: "canceled")
        XCTAssertFalse(VenmoError.isCheckoutCanceled(error))
    }
}
