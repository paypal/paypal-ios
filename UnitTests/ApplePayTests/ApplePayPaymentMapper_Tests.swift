import Contacts
import PassKit
import XCTest
@testable import ApplePay
@testable import CorePayments

final class ApplePayPaymentMapper_Tests: XCTestCase {

    func testPaymentRequest_mapsPayPalConfigOntoPassKit() throws {
        let request = ApplePayRequest(
            orderID: "ORDER-1",
            merchantIdentifier: "merchant.com.example",
            currencyCode: "USD",
            total: ApplePaySummaryItem(label: "Total", amount: Decimal(string: "12.50") ?? 0),
            lineItems: [ApplePaySummaryItem(label: "Subtotal", amount: Decimal(string: "12.50") ?? 0)],
            requiresBillingContact: true,
            requiresShippingContact: false
        )
        let config = ApplePayConfig(
            isEligible: true,
            merchantCountry: "US",
            merchantCapabilities: ["supports3DS", "supportsDebit"],
            supportedNetworks: ["visa", "masterCard", "not-a-network"],
            tokenNotificationURL: nil
        )

        let paymentRequest = try ApplePayPaymentRequestBuilder.make(request: request, config: config)

        XCTAssertEqual(paymentRequest.merchantIdentifier, "merchant.com.example")
        XCTAssertEqual(paymentRequest.countryCode, "US")
        XCTAssertEqual(paymentRequest.currencyCode, "USD")
        XCTAssertEqual(paymentRequest.supportedNetworks, [.visa, .masterCard])
        XCTAssertTrue(paymentRequest.merchantCapabilities.contains(.threeDSecure))
        XCTAssertTrue(paymentRequest.merchantCapabilities.contains(.debit))
        XCTAssertEqual(paymentRequest.paymentSummaryItems.map(\.label), ["Subtotal", "Total"])
        XCTAssertEqual(paymentRequest.paymentSummaryItems.last?.amount, NSDecimalNumber(string: "12.50"))
        XCTAssertEqual(paymentRequest.requiredBillingContactFields, ApplePayPaymentRequestBuilder.contactFields)
        XCTAssertTrue(paymentRequest.requiredShippingContactFields.isEmpty)
    }

    func testPaymentRequest_whenNoNetworksMatch_throws() {
        let request = ApplePayRequest(
            orderID: "ORDER-1",
            merchantIdentifier: "merchant.com.example",
            currencyCode: "USD",
            total: ApplePaySummaryItem(label: "Total", amount: 1)
        )
        let config = ApplePayConfig(
            isEligible: true,
            merchantCountry: "US",
            merchantCapabilities: [],
            supportedNetworks: ["not-a-network"],
            tokenNotificationURL: nil
        )

        XCTAssertThrowsError(try ApplePayPaymentRequestBuilder.make(request: request, config: config)) { error in
            let error = error as? CoreSDKError
            XCTAssertEqual(error?.code, ApplePayError.Code.noSupportedNetworks.rawValue)
        }
    }

    func testContact_uppercasesCountryCodeInThePayPalPayload() throws {
        let postal = CNMutablePostalAddress()
        postal.street = "1 Main\nSuite 2"
        postal.city = "Austin"
        postal.state = "TX"
        postal.postalCode = "78701"
        postal.isoCountryCode = "us"
        let contact = PKContact()
        contact.emailAddress = "buyer@example.com"
        contact.postalAddress = postal

        let mapped = try XCTUnwrap(ApplePayPaymentMapper.contact(from: contact))
        let data = try JSONEncoder().encode(mapped)
        let json = try XCTUnwrap(try JSONSerialization.jsonObject(with: data) as? [String: Any])

        XCTAssertEqual(json["countryCode"] as? String, "US")
        XCTAssertEqual(json["emailAddress"] as? String, "buyer@example.com")
        XCTAssertEqual(json["locality"] as? String, "Austin")
        XCTAssertEqual(json["addressLines"] as? [String], ["1 Main", "Suite 2"])
    }

    func testPaymentToken_rejectsNonObjectPaymentData() {
        let data = Data("\"just-a-string\"".utf8)
        XCTAssertThrowsError(
            try ApplePayPaymentMapper.paymentToken(
                paymentData: data,
                displayName: nil,
                network: nil,
                type: nil,
                transactionIdentifier: "txn"
            )
        )
    }
}
