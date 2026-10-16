import PassKit
import XCTest
@testable import ApplePay
@testable import CorePayments

final class ApplePayClient_Tests: XCTestCase {

    private var service: MockApplePayService!
    private var authorizer: MockApplePayAuthorizer!
    private var client: ApplePayClient!
    private var events: [String] = []

    override func setUp() {
        super.setUp()
        service = MockApplePayService()
        authorizer = MockApplePayAuthorizer()
        events = []
        client = ApplePayClient(service: service, authorizer: authorizer) { name, _ in
            self.events.append(name)
        }
    }

    func testApproveOrder_confirmsTokenAndReturnsApprovedOrder() async throws {
        let result = try await client.approveOrder(request: sampleRequest)

        XCTAssertEqual(result.orderID, "ORDER-1")
        XCTAssertEqual(result.status, "APPROVED")
        XCTAssertEqual(service.confirmedOrderID, "ORDER-1")
        XCTAssertEqual(authorizer.requests.count, 1)
        XCTAssertEqual(authorizer.requests.first?.merchantIdentifier, "merchant.com.example")
        XCTAssertEqual(authorizer.requests.first?.currencyCode, "USD")
        XCTAssertEqual(authorizer.requests.first?.countryCode, "US")
        XCTAssertEqual(events, ["apple-pay:approve-order:started", "apple-pay:approve-order:succeeded"])
    }

    func testApproveOrder_whenMerchantIsNotEligible_doesNotPresentTheSheet() async {
        service.config = ApplePayConfig(
            isEligible: false,
            merchantCountry: "US",
            merchantCapabilities: ["supports3DS"],
            supportedNetworks: ["visa"],
            tokenNotificationURL: nil
        )

        do {
            _ = try await client.approveOrder(request: sampleRequest)
            XCTFail("Expected ineligible")
        } catch let error as CoreSDKError {
            XCTAssertEqual(error.code, ApplePayError.Code.notEligible.rawValue)
            XCTAssertTrue(authorizer.requests.isEmpty)
            XCTAssertEqual(events.last, "apple-pay:approve-order:failed")
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }

    func testApproveOrder_whenBuyerCancels_reportsCancellation() async {
        authorizer.error = ApplePayError.canceled

        do {
            _ = try await client.approveOrder(request: sampleRequest)
            XCTFail("Expected cancel")
        } catch {
            XCTAssertTrue(ApplePayError.isCanceled(error))
            XCTAssertEqual(events.last, "apple-pay:approve-order:canceled")
        }
    }

    func testApproveOrder_completionReturnsTheOrder() {
        let expectation = expectation(description: "approved")
        client.approveOrder(request: sampleRequest) { result in
            if case .success(let value) = result {
                XCTAssertEqual(value.status, "APPROVED")
            } else {
                XCTFail("Expected success")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)
    }

    private var sampleRequest: ApplePayRequest {
        ApplePayRequest(
            orderID: "ORDER-1",
            merchantIdentifier: "merchant.com.example",
            currencyCode: "USD",
            total: ApplePaySummaryItem(label: "Demo", amount: Decimal(string: "10.00") ?? 10)
        )
    }
}

private final class MockApplePayService: ApplePayServicing {

    var config = ApplePayConfig(
        isEligible: true,
        merchantCountry: "US",
        merchantCapabilities: ["supports3DS", "supportsCredit"],
        supportedNetworks: ["visa", "masterCard"],
        tokenNotificationURL: nil
    )
    var confirmedOrderID: String?

    func fetchConfig(buyerCountry: String?) async throws -> ApplePayConfig {
        config
    }

    func confirm(orderID: String, authorization: ApplePayAuthorization) async throws -> String {
        confirmedOrderID = orderID
        XCTAssertEqual(authorization.token.transactionIdentifier, "txn-1")
        return "APPROVED"
    }
}

private final class MockApplePayAuthorizer: ApplePayAuthorizing {

    var requests: [PKPaymentRequest] = []
    var error: CoreSDKError?

    func authorize(
        _ request: PKPaymentRequest,
        confirm: @escaping (ApplePayAuthorization) async throws -> Void
    ) async throws {
        requests.append(request)
        if let error {
            throw error
        }
        let paymentData = Data(#"{"version":"EC_v1","data":"encrypted"}"#.utf8)
        let token = try ApplePayPaymentMapper.paymentToken(
            paymentData: paymentData,
            displayName: "Visa 1111",
            network: "Visa",
            type: "debit",
            transactionIdentifier: "txn-1"
        )
        try await confirm(ApplePayAuthorization(
            token: token,
            billingContact: ApplePayPaymentContact(),
            shippingContact: nil
        ))
    }
}
