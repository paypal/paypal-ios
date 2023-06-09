import XCTest
import SwiftUI
import AuthenticationServices
@testable import CorePayments
@testable import CardPayments
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
    var cardRequest: CardRequest!
    // swiftlint:enable implicitly_unwrapped_optional

    // MARK: - Test lifecycle

    override func setUp() {
        super.setUp()
        config = CoreConfig(clientID: mockClientID, environment: .sandbox)
        mockAPIClient = MockAPIClient(coreConfig: config)
        cardRequest = CardRequest(orderID: "testOrderId", card: card)

        cardClient = CardClient(
            config: config,
            apiClient: mockAPIClient,
            webAuthenticationSession: mockWebAuthSession
        )
    }

    // MARK: - approveOrder() tests
    
    func testApproveOrder_withInvalid3DSURL_returnsError() {
        mockAPIClient.cannedJSONResponse = CardResponses.confirmPaymentSourceJsonInvalid3DSURL.rawValue
        
        let expectation = expectation(description: "approveOrder() completed")

        let mockCardDelegate = MockCardDelegate(success: {_, _ in
            XCTFail("Invoked success() callback. Should invoke error().")
        }, error: { _, err in
            XCTAssertEqual(err.code, 3)
            XCTAssertEqual(err.domain, "CardClientErrorDomain")
            XCTAssertEqual(err.errorDescription, "An invalid 3DS URL was returned. Contact developer.paypal.com/support.")
            expectation.fulfill()
        }, threeDSWillLaunch: { _ in
            XCTFail("Invoked willLaunch() callback. Should invoke error().")
        })

        cardClient.delegate = mockCardDelegate
        cardClient.approveOrder(request: cardRequest)

        waitForExpectations(timeout: 10)
    }

    func testApproveOrder_withNoThreeDSecure_returnsOrderData() {
        mockAPIClient.cannedJSONResponse = CardResponses.confirmPaymentSourceJson.rawValue
        
        let expectation = expectation(description: "approveOrder() completed")

        let mockCardDelegate = MockCardDelegate(success: {_, result -> Void in
            XCTAssertEqual(result.orderID, "testOrderId")
            expectation.fulfill()
        }, error: { _, _ in
            XCTFail("Invoked error() callback. Should invoke success().")
        }, threeDSWillLaunch: { _ in
            XCTFail("Invoked willLaunch() callback. Should invoke success().")
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
            
        let expectation = expectation(description: "approveOrder() completed")

        let mockCardDelegate = MockCardDelegate(success: {_, _ -> Void in
            XCTFail("Invoked success() callback. Should invoke error().")
        }, error: { _, error in
            XCTAssertEqual(error.domain, APIClientError.domain)
            XCTAssertEqual(error.code, APIClientError.Code.jsonDecodingError.rawValue)
            XCTAssertNotNil(error.localizedDescription)
            expectation.fulfill()
        }, threeDSWillLaunch: { _ in
            XCTFail("Invoked willLaunch() callback. Should invoke error().")
        })

        cardClient.delegate = mockCardDelegate
        cardClient.approveOrder(request: cardRequest)
        
        waitForExpectations(timeout: 10)
    }

    func testApproveOrder_withThreeDSecure_browserSwitchLaunches_getOrderReturnsSuccess() {
        mockAPIClient.cannedJSONResponse = CardResponses.successfullGetOrderJson.rawValue
        
        let expectation = expectation(description: "approveOrder() completed")
                
        let mockCardDelegate = MockCardDelegate(
            success: {_, result in
                XCTAssertEqual(result.orderID, "testOrderId")
                expectation.fulfill()
            },
            error: { _, error in
                XCTFail(error.localizedDescription)
                expectation.fulfill()
            },
            cancel: { _ in XCTFail("Invoked cancel() callback. Should invoke success().") },
            threeDSWillLaunch: { _ -> Void in XCTAssert(true) },
            threeDSLaunched: { _ -> Void in XCTAssert(true) })
        
        cardClient.delegate = mockCardDelegate
        cardClient.approveOrder(request: cardRequest)
        
        waitForExpectations(timeout: 10)
    }

    func testApproveOrder_withThreeDSecure_userCancelsBrowser() {
        mockAPIClient.cannedJSONResponse = CardResponses.confirmPaymentSourceJsonWith3DS.rawValue

        mockWebAuthSession.cannedErrorResponse = ASWebAuthenticationSessionError(
            .canceledLogin,
            userInfo: ["Description": "Mock cancellation error description."]
        )
        
        let expectation = expectation(description: "approveOrder() completed")

        let mockCardDelegate = MockCardDelegate(
            success: {_, _ in
                XCTFail("Invoked success() callback. Should invoke cancel().")
                expectation.fulfill()
            },
            error: { _, error in
                XCTFail(error.localizedDescription)
                expectation.fulfill()
            },
            cancel: { _ in
                XCTAssert(true)
                expectation.fulfill()
            },
            threeDSWillLaunch: { _ in XCTAssert(true) },
            threeDSLaunched: { _ in XCTAssert(true) })

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

        let expectation = expectation(description: "approveOrder() completed")

        let mockCardDelegate = MockCardDelegate(
            success: {_, _ in
                XCTFail("Invoked success() callback. Should invoke error().")
                expectation.fulfill()
            },
            error: { _, error in
                XCTAssertEqual(error.domain, CardClientError.domain)
                XCTAssertEqual(error.code, CardClientError.Code.threeDSecureError.rawValue)
                XCTAssertEqual(error.localizedDescription, "Mock web session error description.")
                expectation.fulfill()
            },
            cancel: { _ in
                XCTFail("Invoked cancel() callback. Should invoke error().")
                expectation.fulfill()
            },
            threeDSWillLaunch: { _ in XCTAssert(true) },
            threeDSLaunched: { _ in XCTAssert(true) })

        cardClient.delegate = mockCardDelegate
        cardClient.approveOrder(request: cardRequest)

        waitForExpectations(timeout: 10)
    }
}
