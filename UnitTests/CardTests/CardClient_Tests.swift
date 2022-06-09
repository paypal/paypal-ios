import XCTest
@testable import PaymentsCore
@testable import Card
@testable import TestShared
import SwiftUI

class CardClient_Tests: XCTestCase {

    // MARK: - Helper Properties

    // swiftlint:disable:next force_unwrapping
    let successURLResponse = HTTPURLResponse(url: URL(string: "www.test.com")!, statusCode: 200, httpVersion: "https", headerFields: [:])!
    let card = Card(
        number: "411111111111",
        expirationMonth: "01",
        expirationYear: "2021",
        securityCode: "123"
    )
    let config = CoreConfig(clientID: "", secret: "", environment: .sandbox)

    // swiftlint:disable implicitly_unwrapped_optional
    var mockURLSession: MockQuededURLSession!
    var apiClient: APIClient!
    var cardClient: CardClient!
    // swiftlint:enable implicitly_unwrapped_optional

    // MARK: - Test lifecycle

    override func setUp() {
        super.setUp()

        mockURLSession = MockQuededURLSession()

        apiClient = APIClient(urlSession: mockURLSession, environment: .sandbox)
        cardClient = CardClient(config: config, apiClient: apiClient)
    }

    // MARK: - approveOrder() tests

    func testApproveOrder_withNoThreeDSecure_returnsOrderData() {

        if let jsonResponse = """
        {
            "id": "testOrderID",
            "status": "APPROVED",
            "payment_source": {
                "card": {
                    "last_four_digits": "7321",
                    "brand": "VISA",
                    "type": "CREDIT"
                }
            }
        }
        """.data(using: String.Encoding.utf8) {
            let mockResponse = MockResponse.success(
                MockResponse.Success(data: jsonResponse, urlResponse: successURLResponse)
            )
            mockURLSession.addResponse(mockResponse)
            let expectation = expectation(description: "testName")

            let cardRequest = CardRequest(card: card)

            cardClient.delegate = MockCardDelegate(success: {_, result -> Void in
                XCTAssertEqual(result.orderID, "testOrderID")
                XCTAssertEqual(result.paymentSource?.card.brand, "VISA")
                XCTAssertEqual(result.paymentSource?.card.lastFourDigits, "7321")
                XCTAssertEqual(result.paymentSource?.card.type, "CREDIT")
                expectation.fulfill()
            }, error: { _, _ -> Void in
                XCTFail()
            }, threeDSWillLaunch: { _ -> Void in
                XCTFail()
            })

            cardClient.start(
                orderId: "testOrderID",
                request: cardRequest,
                context: MockViewController(),
                webAuthenticationSession: MockWebAuthenticationSession()
            )

            waitForExpectations(timeout: 10)
        } else {
            XCTFail("Data json cannot be null")
        }
    }

    func testApproveOrder_withInvalidJSONResponse_returnsParseError() {

        if let jsonResponse = """
        {
            "some_unexpected_response": "something"
        }
        """.data(using: String.Encoding.utf8) {
            let mockResponse = MockResponse.success(
                MockResponse.Success(data: jsonResponse, urlResponse: successURLResponse)
            )
            mockURLSession.addResponse(mockResponse)
            let expectation = expectation(description: "testName")

            let cardRequest = CardRequest(card: card)

            cardClient.delegate = MockCardDelegate(success: {_, result -> Void in
                XCTFail("Test Should have thrown an error")
            }, error: { _, error -> Void in
                XCTAssertEqual(error.domain, APIClientError.domain)
                XCTAssertEqual(error.code, APIClientError.Code.dataParsingError.rawValue)
                XCTAssertEqual(error.localizedDescription, "An error occured parsing HTTP response data. Contact developer.paypal.com/support.")
                expectation.fulfill()
            }, threeDSWillLaunch: { _ -> Void in
                XCTFail()
            })

            cardClient.start(
                orderId: "testOrderID",
                request: cardRequest,
                context: MockViewController(),
                webAuthenticationSession: MockWebAuthenticationSession()
            )

            waitForExpectations(timeout: 10)
        } else {
            XCTFail("Data json cannot be null")
        }
    }

    private class MockCardDelegate: CardDelegate {

        private var success: ((CardClient, CardResult) -> Void)
        private var failure: ((CardClient, CoreSDKError) -> Void)?
        private var cancel: ((CardClient) -> Void)?
        private var threeDSWillLaunch: ((CardClient) -> Void)?
        private var threeDSLaunched: ((CardClient) -> Void)?

        required init(
            success: @escaping((CardClient, CardResult) -> Void),
            error: ((CardClient, CoreSDKError) -> Void)? = nil,
            cancel: ((CardClient) -> Void)? = nil,
            threeDSWillLaunch: ((CardClient) -> Void)? = nil,
            threeDSLaunched: ((CardClient) -> Void)? = nil
        ) {
            self.success = success
            self.failure = error
            self.cancel = cancel
            self.threeDSWillLaunch = threeDSWillLaunch
            self.threeDSLaunched = threeDSLaunched
        }

        func card(_ cardClient: CardClient, didFinishWithResult result: CardResult) {
            success(cardClient, result)
        }

        func card(_ cardClient: CardClient, didFinishWithError error: CoreSDKError) {
            failure?(cardClient, error)
        }

        func cardDidCancel(_ cardClient: CardClient) {
            cancel?(cardClient)
        }

        func cardThreeDSecureWillLaunch(_ cardClient: CardClient) {
            threeDSWillLaunch?(cardClient)
        }

        func cardThreeDSecureDidFinish(_ cardClient: CardClient) {
            threeDSLaunched?(cardClient)
        }
    }
}
