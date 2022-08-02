import XCTest
import SwiftUI
import AuthenticationServices
@testable import PaymentsCore
@testable import Card
@testable import TestShared

class CardClient_Tests: XCTestCase {

    let mockClientId = "mockClientId"
    let mockAccessToken = "mockAccessToken"

    // MARK: - Helper Properties

    // swiftlint:disable:next force_unwrapping
    let successURLResponse = HTTPURLResponse(url: URL(string: "www.test.com")!, statusCode: 200, httpVersion: "https", headerFields: [:])!
    let card = Card(
        number: "411111111111",
        expirationMonth: "01",
        expirationYear: "2021",
        securityCode: "123"
    )

    // swiftlint:disable implicitly_unwrapped_optional
    var config: CoreConfig!
    var mockURLSession: MockQuededURLSession!
    var apiClient: APIClient!
    var cardClient: CardClient!
    // swiftlint:enable implicitly_unwrapped_optional

    // MARK: - Test lifecycle

    override func setUp() {
        super.setUp()
        config = CoreConfig(accessToken: mockAccessToken, environment: .sandbox)
        mockURLSession = MockQuededURLSession()

        apiClient = APIClient(urlSession: mockURLSession, coreConfig: config)
        cardClient = CardClient(config: config, apiClient: apiClient)
    }

    override func tearDown() {
        super.tearDown()
        mockURLSession.clear()
    }

    // MARK: - approveOrder() tests

    func testApproveOrder_withNoThreeDSecure_returnsOrderData() {
        if let jsonResponse = CardResponses.confirmPaymentSourceJson.rawValue.data(using: String.Encoding.utf8) {
            let mockResponse = MockResponse.success(
                MockResponse.Success(data: jsonResponse, urlResponse: successURLResponse)
            )
            mockURLSession.addResponse(mockResponse)
            let expectation = expectation(description: "testName")

            let cardRequest = CardRequest(orderID: "testOrderId", card: card)

            let mockCardDelegate = MockCardDelegate(success: {_, result -> Void in
                XCTAssertEqual(result.orderID, "testOrderId")
                XCTAssertEqual(result.paymentSource?.card.brand, "VISA")
                XCTAssertEqual(result.paymentSource?.card.lastFourDigits, "7321")
                XCTAssertEqual(result.paymentSource?.card.type, "CREDIT")
                expectation.fulfill()
            }, error: { _, _ -> Void in
                XCTFail()
            }, threeDSWillLaunch: { _ -> Void in
                XCTFail()
            })

            cardClient.delegate = mockCardDelegate

            cardClient.start(
                request: cardRequest,
                context: MockViewController(),
                webAuthenticationSession: MockWebAuthenticationSession()
            )

            waitForExpectations(timeout: 10)
        } else {
            XCTFail("Data json cannot be null")
        }
    }

    func testApproveOrder_whenApiCallFails_returnsError() {
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

            let cardRequest = CardRequest(orderID: "testOrderId", card: card)

            let mockCardDelegate = MockCardDelegate(success: {_, _ -> Void in
                XCTFail("Test Should have thrown an error")
            }, error: { _, error -> Void in
                XCTAssertEqual(error.domain, APIClientError.domain)
                XCTAssertEqual(error.code, APIClientError.Code.dataParsingError.rawValue)
                XCTAssertEqual(error.localizedDescription, "An error occured parsing HTTP response data. Contact developer.paypal.com/support.")
                expectation.fulfill()
            }, threeDSWillLaunch: { _ -> Void in
                XCTFail()
            })

            cardClient.delegate = mockCardDelegate

            cardClient.start(
                request: cardRequest,
                context: MockViewController(),
                webAuthenticationSession: MockWebAuthenticationSession()
            )
            waitForExpectations(timeout: 10)
        } else {
            XCTFail("Data json cannot be null")
        }
    }

    func testApproveOrder_withThreeDSecure_browserSwitchLaunches_getOrderReturnsSuccess() {
        if let confirmPaymentSourceJsonResponse = CardResponses.confirmPaymentSourceJsonWith3DS.rawValue.data(using: String.Encoding.utf8),
            let getOrderJsonResponse = CardResponses.successfullGetOrderJson.rawValue.data(using: String.Encoding.utf8) {
            let mockConfirmResponse = MockResponse.success(
                MockResponse.Success(data: confirmPaymentSourceJsonResponse, urlResponse: successURLResponse)
            )
            let mockOrderResponse = MockResponse.success(
                MockResponse.Success(data: getOrderJsonResponse, urlResponse: successURLResponse)
            )

            mockURLSession.addResponse(mockConfirmResponse)
            mockURLSession.addResponse(mockOrderResponse)

            let expectation = expectation(description: "testName")

            let threeDSecureRequest = ThreeDSecureRequest(sca: .scaAlways, returnUrl: "", cancelUrl: "")
            let cardRequest = CardRequest(orderID: "testOrderId", card: card, threeDSecureRequest: threeDSecureRequest)

            let mockCardDelegate = MockCardDelegate(
                success: {_, result -> Void in
                    XCTAssertEqual(result.orderID, "testOrderId")
                    XCTAssertEqual(result.status, "CREATED")
                    XCTAssertEqual(result.paymentSource?.card.brand, "VISA")
                    XCTAssertEqual(result.paymentSource?.card.lastFourDigits, "7321")
                    XCTAssertEqual(result.paymentSource?.card.type, "CREDIT")
                    XCTAssertEqual(result.paymentSource?.card.authenticationResult?.liabilityShift, "POSSIBLE")
                    XCTAssertEqual(result.paymentSource?.card.authenticationResult?.threeDSecure?.authenticationStatus, "Y")
                    XCTAssertEqual(result.paymentSource?.card.authenticationResult?.threeDSecure?.enrollmentStatus, "Y")
                    expectation.fulfill()
                },
                error: { _, error -> Void in
                    XCTFail(error.localizedDescription)
                    expectation.fulfill()
                },
                cancel: { _ -> Void in XCTFail("Cancel in delegate shouldnt be called") },
                threeDSWillLaunch: { _ -> Void in XCTAssert(true) },
                threeDSLaunched: { _ -> Void in XCTAssert(true) })

            cardClient.delegate = mockCardDelegate

            cardClient.start(
                request: cardRequest,
                context: MockViewController(),
                webAuthenticationSession: MockWebAuthenticationSession()
            )

            waitForExpectations(timeout: 10)
        } else {
            XCTFail("Data json cannot be null")
        }
    }

    func testApproveOrder_withThreeDSecure_userCancelsBrowser() {
        if let confirmPaymentSourceJsonResponse = CardResponses.confirmPaymentSourceJsonWith3DS.rawValue.data(using: String.Encoding.utf8) {
            let mockConfirmResponse = MockResponse.success(
                MockResponse.Success(data: confirmPaymentSourceJsonResponse, urlResponse: successURLResponse)
            )

            mockURLSession.addResponse(mockConfirmResponse)

            let mockWebAuthSession = MockWebAuthenticationSession()
            mockWebAuthSession.cannedErrorResponse = ASWebAuthenticationSessionError(
                _bridgedNSError: NSError(
                    domain: ASWebAuthenticationSessionError.errorDomain,
                    code: ASWebAuthenticationSessionError.canceledLogin.rawValue,
                    userInfo: ["Description": "Mock cancellation error description."]
                )
            )

            let expectation = expectation(description: "testName")

            let threeDSecureRequest = ThreeDSecureRequest(sca: .scaAlways, returnUrl: "", cancelUrl: "")
            let cardRequest = CardRequest(orderID: "testOrderId", card: card, threeDSecureRequest: threeDSecureRequest)

            let mockCardDelegate = MockCardDelegate(
                success: {_, _ -> Void in
                    XCTFail("Flow should not succed")
                    expectation.fulfill()
                },
                error: { _, error -> Void in
                    XCTFail(error.localizedDescription)
                    expectation.fulfill()
                },
                cancel: { _ -> Void in
                    XCTAssert(true)
                    expectation.fulfill()
                },
                threeDSWillLaunch: { _ -> Void in XCTAssert(true) },
                threeDSLaunched: { _ -> Void in XCTAssert(true) })

            cardClient.delegate = mockCardDelegate

            cardClient.start(
                request: cardRequest,
                context: MockViewController(),
                webAuthenticationSession: mockWebAuthSession
            )

            waitForExpectations(timeout: 10)
        } else {
            XCTFail("Data json cannot be null")
        }
    }

    func testApproveOrder_withThreeDSecure_browserReturnsError() {
        if let confirmPaymentSourceJsonResponse = CardResponses.confirmPaymentSourceJsonWith3DS.rawValue.data(using: String.Encoding.utf8) {
            let mockConfirmResponse = MockResponse.success(
                MockResponse.Success(data: confirmPaymentSourceJsonResponse, urlResponse: successURLResponse)
            )

            mockURLSession.addResponse(mockConfirmResponse)

            let mockWebAuthSession = MockWebAuthenticationSession()
            mockWebAuthSession.cannedErrorResponse = CoreSDKError(
                code: CardClientError.Code.threeDSecureError.rawValue,
                domain: CardClientError.domain,
                errorDescription: "Mock web session error description."
            )

            let expectation = expectation(description: "testName")

            let threeDSecureRequest = ThreeDSecureRequest(sca: .scaAlways, returnUrl: "", cancelUrl: "")
            let cardRequest = CardRequest(orderID: "testOrderId", card: card, threeDSecureRequest: threeDSecureRequest)

            let mockCardDelegate = MockCardDelegate(
                success: {_, _ -> Void in
                    XCTFail("Flow should not succed")
                    expectation.fulfill()
                },
                error: { _, error -> Void in
                    XCTAssertEqual(error.domain, CardClientError.domain)
                    XCTAssertEqual(error.code, CardClientError.Code.threeDSecureError.rawValue)
                    XCTAssertEqual(error.localizedDescription, "Mock web session error description.")
                    expectation.fulfill()
                },
                cancel: { _ -> Void in
                    XCTFail("Flow should not cancel")
                    expectation.fulfill()
                },
                threeDSWillLaunch: { _ -> Void in XCTAssert(true) },
                threeDSLaunched: { _ -> Void in XCTAssert(true) })

            cardClient.delegate = mockCardDelegate

            cardClient.start(
                request: cardRequest,
                context: MockViewController(),
                webAuthenticationSession: mockWebAuthSession
            )

            waitForExpectations(timeout: 10)
        } else {
            XCTFail("Data json cannot be null")
        }
    }
}
