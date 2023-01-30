import XCTest
import SwiftUI
import AuthenticationServices
@testable import PaymentsCore
@testable import Card
@testable import TestShared

class CardClient_Tests: XCTestCase {

    let mockClientID = "mockClientId"
    let mockAccessToken = "mockAccessToken"

    // MARK: - Helper Properties

    let card = Card(
        number: "411111111111",
        expirationMonth: "01",
        expirationYear: "2021",
        securityCode: "123"
    )
    
    let mockWebAuthSession = MockWebAuthenticationSession()

    // swiftlint:disable implicitly_unwrapped_optional
    var config: CoreConfig!
    var mockAPIClient: MockAPIClient!
    var cardClient: CardClient!
    // swiftlint:enable implicitly_unwrapped_optional

    // MARK: - Test lifecycle

    override func setUp() {
        super.setUp()
        config = CoreConfig(accessToken: mockAccessToken, environment: .sandbox)
        mockAPIClient = MockAPIClient(coreConfig: config)

        cardClient = CardClient(
            config: config,
            apiClient: mockAPIClient,
            webAuthenticationSession: mockWebAuthSession
        )
    }

    // MARK: - approveOrder() tests

    func testApproveOrder_withNoThreeDSecure_returnsOrderData() {
        mockAPIClient.cannedJSONResponse = CardResponses.confirmPaymentSourceJson.rawValue
        
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

        cardClient.approveOrder(request: cardRequest)

        waitForExpectations(timeout: 10)
    }

    func testApproveOrder_whenApiCallFails_returnsError() {
        mockAPIClient.cannedJSONResponse = """
        {
            "some_unexpected_response": "something"
        }
        """
            
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

        cardClient.approveOrder(request: cardRequest)
        
        waitForExpectations(timeout: 10)
    }

    func testApproveOrder_withThreeDSecure_browserSwitchLaunches_getOrderReturnsSuccess() {
        mockAPIClient.cannedJSONResponse = CardResponses.successfullGetOrderJson.rawValue
        
        let expectation = expectation(description: "testName")
        
        let cardRequest = CardRequest(orderID: "testOrderId", card: card)
        
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
        
        cardClient.approveOrder(request: cardRequest)
        
        waitForExpectations(timeout: 10)
    }

    func testApproveOrder_withThreeDSecure_userCancelsBrowser() {
        mockAPIClient.cannedJSONResponse = CardResponses.confirmPaymentSourceJsonWith3DS.rawValue

        mockWebAuthSession.cannedErrorResponse = ASWebAuthenticationSessionError(
            _bridgedNSError: NSError(
                domain: ASWebAuthenticationSessionError.errorDomain,
                code: ASWebAuthenticationSessionError.canceledLogin.rawValue,
                userInfo: ["Description": "Mock cancellation error description."]
            )
        )

        let expectation = expectation(description: "testName")

        let cardRequest = CardRequest(orderID: "testOrderId", card: card)

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

        cardClient.approveOrder(request: cardRequest)

        waitForExpectations(timeout: 10)
    }

    func testApproveOrder_withThreeDSecure_browserReturnsError() {
        mockAPIClient.cannedJSONResponse = CardResponses.confirmPaymentSourceJsonWith3DS.rawValue
        
        mockWebAuthSession.cannedErrorResponse = CoreSDKError(
            code: CardClientError.Code.threeDSecureError.rawValue,
            domain: CardClientError.domain,
            errorDescription: "Mock web session error description."
        )

        let expectation = expectation(description: "testName")

        let cardRequest = CardRequest(orderID: "testOrderId", card: card)

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

        cardClient.approveOrder(request: cardRequest)

        waitForExpectations(timeout: 10)
    }
}
