import XCTest
import SwiftUI
import AuthenticationServices
@testable import CorePayments
@testable import CardPayments
@testable import TestShared

// swiftlint:disable type_body_length
class CardClient_Tests: XCTestCase {

    // MARK: - Helper Properties

    let card = Card(
        number: "411111111111",
        expirationMonth: "01",
        expirationYear: "2021",
        securityCode: "123"
    )
    let config = CoreConfig(clientID: "mockClientId", environment: .sandbox)
    var cardRequest: CardRequest!
    var cardVaultRequest: CardVaultRequest!

    let mockWebAuthSession = MockWebAuthenticationSession()
    var mockNetworkingClient: MockNetworkingClient!
    var mockCardVaultDelegate: MockCardVaultDelegate!
    var mockCheckoutOrdersAPI: MockCheckoutOrdersAPI!
    var mockVaultAPI: MockVaultPaymentTokensAPI!

    var sut: CardClient!
    
    // MARK: - Test lifecycle

    override func setUp() {
        super.setUp()
        mockNetworkingClient = MockNetworkingClient(coreConfig: config)
        cardRequest = CardRequest(orderID: "testOrderId", card: card)
        cardVaultRequest = CardVaultRequest(card: card, setupTokenID: "testSetupTokenId")

        mockCheckoutOrdersAPI = MockCheckoutOrdersAPI(coreConfig: config, networkingClient: mockNetworkingClient)
        
        mockVaultAPI = MockVaultPaymentTokensAPI(coreConfig: config, networkingClient: mockNetworkingClient)
        
        sut = CardClient(
            config: config,
            checkoutOrdersAPI: mockCheckoutOrdersAPI,
            vaultAPI: mockVaultAPI,
            webAuthenticationSession: mockWebAuthSession
        )
    }
    
    // MARK: - vault() tests

    func testVault_withValidResponse_returnsSuccess() {
        let setupTokenID = "testToken1"
        let vaultStatus = "APPROVED"
        let vaultRequest = CardVaultRequest(card: card, setupTokenID: setupTokenID)
        let updateSetupTokenResponse = UpdateSetupTokenResponse(
            updateVaultSetupToken: TokenDetails(id: setupTokenID, status: vaultStatus, links: [TokenDetails.Link(rel: "df", href: "h")])
        )
        mockVaultAPI.stubSetupTokenResponse = updateSetupTokenResponse
        
        let expectation = expectation(description: "vault completed")
        let cardVaultDelegate = MockCardVaultDelegate(success: {_, result in
            XCTAssertEqual(result.setupTokenID, setupTokenID)
            XCTAssertEqual(result.status, vaultStatus)
            XCTAssertFalse(result.didAttemptThreeDSecureAuthentication)
            expectation.fulfill()
        }, error: {_, _ in
            XCTFail("Invoked error() callback. Should invoke success().")
        })
        sut.vaultDelegate = cardVaultDelegate
        sut.vault(vaultRequest)
        
        waitForExpectations(timeout: 10)
    }
 
    func testVault_withValid3DSURLResponse_returnsSuccess() {
        let setupTokenID = "testToken1"
        let vaultStatus = "PAYER_ACTION_REQUIRED"
        let vaultRequest = CardVaultRequest(card: card, setupTokenID: setupTokenID)
        let updateSetupTokenResponse = UpdateSetupTokenResponse(
            updateVaultSetupToken: TokenDetails(id: setupTokenID, status: vaultStatus, links: [TokenDetails.Link(rel: "approve", href: "https://www.sandbox.paypal.com/webapps/helios?action=authenticate&token=6WX01471SY074580E")])
        )
        mockVaultAPI.stubSetupTokenResponse = updateSetupTokenResponse

        let expectation = expectation(description: "vault completed")
        let cardVaultDelegate = MockCardVaultDelegate(success: {_, result in
            XCTAssertEqual(result.setupTokenID, setupTokenID)
            XCTAssertNil(result.status)
            XCTAssertTrue(result.didAttemptThreeDSecureAuthentication)
            expectation.fulfill()
        }, error: {_, _ in
            XCTFail("Invoked error() callback. Should invoke success().")
        })
        sut.vaultDelegate = cardVaultDelegate
        sut.vault(vaultRequest)

        waitForExpectations(timeout: 10)
    }

    func testVault_withInvalid3DSURLResponse_returnsSuccess() {
        let setupTokenID = "testToken1"
        let vaultStatus = "PAYER_ACTION_REQUIRED"
        let vaultRequest = CardVaultRequest(card: card, setupTokenID: setupTokenID)
        let updateSetupTokenResponse = UpdateSetupTokenResponse(
            updateVaultSetupToken: TokenDetails(id: setupTokenID, status: vaultStatus, links: [TokenDetails.Link(rel: "approve", href: "https://www.sandbox.paypal.com/webapps/testBadURL?action=authenticate&token=6WX01471SY074580E")])
        )
        mockVaultAPI.stubSetupTokenResponse = updateSetupTokenResponse

        let expectation = expectation(description: "vault completed")
        let cardVaultDelegate = MockCardVaultDelegate(success: {_, _ in
            XCTFail("Invoked success() callback. Should invoke error().")
        }, error: {_, error in
            XCTAssertEqual(error.code, CardClientError.threeDSecureURLError.code)
            XCTAssertEqual(error.domain, CardClientError.domain)
            XCTAssertEqual(error.localizedDescription, CardClientError.threeDSecureURLError.localizedDescription)
            expectation.fulfill()
        })
        sut.vaultDelegate = cardVaultDelegate
        sut.vault(vaultRequest)

        waitForExpectations(timeout: 10)
    }

    func testVault_whenVaultAPIError_bubblesError() {
        let setupTokenID = "testToken1"
        let vaultRequest = CardVaultRequest(card: card, setupTokenID: setupTokenID)
               
        mockVaultAPI.stubError = CoreSDKError(code: 123, domain: "fake-domain", errorDescription: "api-error")

        let expectation = expectation(description: "vault completed")
        let cardVaultDelegate = MockCardVaultDelegate(success: {_, _ in
            XCTFail("Invoked success() callback. Should invoke error().")
        }, error: {_, error in
            XCTAssertEqual(error.domain, "fake-domain")
            XCTAssertEqual(error.code, 123)
            XCTAssertEqual(error.localizedDescription, "api-error")
            expectation.fulfill()
        })
        sut.vaultDelegate = cardVaultDelegate
        sut.vault(vaultRequest)

        waitForExpectations(timeout: 10)
    }

    func testVault_whenUnknownError_returnsVaultError() {
        let setupTokenID = "testToken1"
        let vaultRequest = CardVaultRequest(card: card, setupTokenID: setupTokenID)

        mockVaultAPI.stubError = NSError(domain: "some-domain", code: 123, userInfo: [NSLocalizedDescriptionKey: "some-description"])

        let expectation = expectation(description: "vault completed")
        let cardVaultDelegate = MockCardVaultDelegate(success: {_, _ in
            XCTFail("Invoked success() callback. Should invoke error().")
        }, error: {_, error in
            XCTAssertEqual(error.domain, CardClientError.domain)
            XCTAssertEqual(error.code, CardClientError.Code.vaultTokenError.rawValue)
            XCTAssertEqual(error.localizedDescription, "An error occurred while vaulting a card.")
            expectation.fulfill()
        })
        sut.vaultDelegate = cardVaultDelegate
        sut.vault(vaultRequest)

        waitForExpectations(timeout: 10)
    }

    func test_vault_withThreeDSecure_browserSwitchLaunches_vaultReturnsSuccess() {
        mockVaultAPI.stubSetupTokenResponse = FakeUpdateSetupTokenResponse.withValid3DSURL

        mockWebAuthSession.cannedResponseURL = .init(string: "sdk.ios.paypal://vault/success")

        let expectation = expectation(description: "vault() completed")

        let mockCardVaultDelegate = MockCardVaultDelegate(
            success: {_, result in
                XCTAssertEqual(result.setupTokenID, "testSetupTokenId")
                XCTAssertNil(result.status)
                XCTAssertTrue(result.didAttemptThreeDSecureAuthentication)
                expectation.fulfill()
            },
            error: { _, error in
                XCTFail(error.localizedDescription)
                expectation.fulfill()
            },
            cancel: { _ in XCTFail("Invoked cancel() callback. Should invoke success().") },
            threeDSWillLaunch: { _ in XCTAssert(true) },
            threeDSLaunched: { _ in XCTAssert(true) }
        )

        sut.vaultDelegate = mockCardVaultDelegate
        sut.vault(cardVaultRequest)

        waitForExpectations(timeout: 10)
    }

    func testVault_withThreeDSecure_userCancelsBrowser() {
        mockVaultAPI.stubSetupTokenResponse = FakeUpdateSetupTokenResponse.withValid3DSURL

        mockWebAuthSession.cannedErrorResponse = ASWebAuthenticationSessionError(
            .canceledLogin,
            userInfo: ["Description": "Mock cancellation error description."]
        )

        let expectation = expectation(description: "vault() completed")

        let mockCardVaultDelegate = MockCardVaultDelegate(
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
            threeDSLaunched: { _ in XCTAssert(true) }
        )

        sut.vaultDelegate = mockCardVaultDelegate
        sut.vault(cardVaultRequest)

        waitForExpectations(timeout: 10)
    }

    func testVault_withThreeDSecure_browserReturnsError() {
        mockVaultAPI.stubSetupTokenResponse = FakeUpdateSetupTokenResponse.withValid3DSURL

        mockWebAuthSession.cannedErrorResponse = CoreSDKError(
            code: CardClientError.Code.threeDSecureError.rawValue,
            domain: CardClientError.domain,
            errorDescription: "Mock web session error description."
        )

        let expectation = expectation(description: "vault() completed")

        let mockCardVaultDelegate = MockCardVaultDelegate(
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
            threeDSLaunched: { _ in XCTAssert(true) }
        )

        sut.vaultDelegate = mockCardVaultDelegate
        sut.vault(cardVaultRequest)

        waitForExpectations(timeout: 10)
    }

    // MARK: - approveOrder() tests

    func testAsyncApproveOrder_withInvalid3DSURL_returnsError() async throws {
        mockCheckoutOrdersAPI.stubConfirmResponse = FakeConfirmPaymentResponse.withInvalid3DSURL

        do {
            _ = try await sut.approveOrderAsync(request: cardRequest)
            XCTFail("Invoked success() callback. Should invoke error().")
        } catch let error as CoreSDKError {
            XCTAssertEqual(error.code, 3)
            XCTAssertEqual(error.domain, "CardClientErrorDomain")
            XCTAssertEqual(error.errorDescription, "An invalid 3DS URL was returned. Contact developer.paypal.com/support.")
        }
    }

    func testAsyncApproveOrder_withNoThreeDSecure_returnsOrderData() async throws {
        mockCheckoutOrdersAPI.stubConfirmResponse = FakeConfirmPaymentResponse.without3DS

        do {
            let result = try await sut.approveOrderAsync(request: cardRequest)
            XCTAssertEqual(result.orderID, "testOrderId")
            XCTAssertEqual(result.status, "APPROVED")
            XCTAssertFalse(result.didAttemptThreeDSecureAuthentication)
        } catch {
            XCTFail("Invoked error() callback. Should invoke success().")
        }
    }

    func testAsyncApproveOrder_whenConfirmPaymentSDKError_bubblesError() async throws {
        mockCheckoutOrdersAPI.stubError = CoreSDKError(code: 123, domain: "sdk-domain", errorDescription: "sdk-error-desc")

        do {
            _ = try await sut.approveOrderAsync(request: cardRequest)
            XCTFail("Invoked success() callback. Should invoke error().")
        } catch let error as CoreSDKError {
            XCTAssertEqual(error.domain, "sdk-domain")
            XCTAssertEqual(error.code, 123)
            XCTAssertEqual(error.localizedDescription, "sdk-error-desc")
        }
    }

    func testAsyncApproveOrder_whenConfirmPaymentGeneralError_returnsUnknownError() async throws {
        mockCheckoutOrdersAPI.stubError = NSError(
            domain: "ns-fake-domain",
            code: 123,
            userInfo: [NSLocalizedDescriptionKey: "ns-fake-error"]
        )

        do {
            _ = try await sut.approveOrderAsync(request: cardRequest)
            XCTFail("Invoked success() callback. Should invoke error().")
        } catch let error as CoreSDKError {
            XCTAssertEqual(error.domain, CardClientError.domain)
            XCTAssertEqual(error.code, CardClientError.Code.unknown.rawValue)
            XCTAssertNotNil(error.localizedDescription)
        }
    }

    func testAsyncApproveOrder_withThreeDSecure_browserSwitchLaunches_getOrderReturnsSuccess() async throws {
        mockCheckoutOrdersAPI.stubConfirmResponse = FakeConfirmPaymentResponse.withValid3DSURL

        mockWebAuthSession.cannedResponseURL = .init(string: "sdk.ios.paypal://card/success?state=undefined&code=undefined&liability_shift=POSSIBLE")

        do {
            let result = try await sut.approveOrderAsync(request: cardRequest)
                XCTAssertEqual(result.orderID, "testOrderId")
                XCTAssertNil(result.status)
                XCTAssertTrue(result.didAttemptThreeDSecureAuthentication)
        } catch {
            XCTFail("Invoked error() callback. Should invoke success().")
        }
    }

    func testAsyncApproveOrder_withThreeDSecure_userCancelsBrowser() async throws {
        mockCheckoutOrdersAPI.stubConfirmResponse = FakeConfirmPaymentResponse.withValid3DSURL

        mockWebAuthSession.cannedErrorResponse = ASWebAuthenticationSessionError(
            .canceledLogin,
            userInfo: ["Description": "Mock cancellation error description."]
        )

        do {
            _ = try await sut.approveOrderAsync(request: cardRequest)
            XCTFail("Invoked success() callback. Should invoke error().")
        } catch let error as CoreSDKError {
            XCTAssertEqual(error.domain, CardClientError.domain)
            XCTAssertEqual(error.code, CardClientError.Code.threeDSCancellation.rawValue)
            XCTAssertNotNil(error.localizedDescription)
        }
    }

    func testAsyncApproveOrder_withThreeDSecure_browserReturnsError() async throws {
        mockCheckoutOrdersAPI.stubConfirmResponse = FakeConfirmPaymentResponse.withValid3DSURL

        mockWebAuthSession.cannedErrorResponse = CoreSDKError(
            code: CardClientError.Code.threeDSecureError.rawValue,
            domain: CardClientError.domain,
            errorDescription: "Mock web session error description."
        )

        do {
            _ = try await sut.approveOrderAsync(request: cardRequest)
            XCTFail("Invoked success() callback. Should invoke error().")
        } catch let error as CoreSDKError {
            XCTAssertEqual(error.domain, CardClientError.domain)
            XCTAssertEqual(error.code, CardClientError.Code.threeDSecureError.rawValue)
            XCTAssertNotNil(error.localizedDescription)
        }
    }
}
