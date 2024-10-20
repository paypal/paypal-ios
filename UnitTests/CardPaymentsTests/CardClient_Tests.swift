import XCTest
import SwiftUI
import AuthenticationServices
@testable import CorePayments
@testable import CardPayments
@testable import TestShared

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

    func testVault_withValidResponse_returnsSuccess() async throws {
        let setupTokenID = "testToken1"
        let vaultStatus = "APPROVED"
        let vaultRequest = CardVaultRequest(card: card, setupTokenID: setupTokenID)
        let updateSetupTokenResponse = UpdateSetupTokenResponse(
            updateVaultSetupToken: TokenDetails(id: setupTokenID, status: vaultStatus, links: [TokenDetails.Link(rel: "df", href: "h")])
        )
        mockVaultAPI.stubSetupTokenResponse = updateSetupTokenResponse

        do {
            let result = try await sut.vault(vaultRequest)
            XCTAssertEqual(result.setupTokenID, setupTokenID)
            XCTAssertEqual(result.status, vaultStatus)
            XCTAssertFalse(result.didAttemptThreeDSecureAuthentication)
        } catch {
            XCTFail("Invoked error() callback. Should invoke success().")
        }
    }

    func testVault_withValid3DSURLResponse_returnsSuccess() async throws {
        let setupTokenID = "testToken1"
        let vaultStatus = "PAYER_ACTION_REQUIRED"
        let vaultRequest = CardVaultRequest(card: card, setupTokenID: setupTokenID)
        let updateSetupTokenResponse = UpdateSetupTokenResponse(
            updateVaultSetupToken: TokenDetails(id: setupTokenID, status: vaultStatus, links: [TokenDetails.Link(rel: "approve", href: "https://www.sandbox.paypal.com/webapps/helios?action=authenticate&token=6WX01471SY074580E")])
        )
        mockVaultAPI.stubSetupTokenResponse = updateSetupTokenResponse

        do {
            let result = try await sut.vault(vaultRequest)
            XCTAssertEqual(result.setupTokenID, setupTokenID)
            XCTAssertNil(result.status)
            XCTAssertTrue(result.didAttemptThreeDSecureAuthentication)
        } catch {
            XCTFail("Invoked error() callback. Should invoke success().")
        }
    }

    func testVault_withInvalid3DSURLResponse_returnsError() async throws {
        let setupTokenID = "testToken1"
        let vaultStatus = "PAYER_ACTION_REQUIRED"
        let vaultRequest = CardVaultRequest(card: card, setupTokenID: setupTokenID)
        let updateSetupTokenResponse = UpdateSetupTokenResponse(
            updateVaultSetupToken: TokenDetails(id: setupTokenID, status: vaultStatus, links: [TokenDetails.Link(rel: "approve", href: "https://www.sandbox.paypal.com/webapps/testBadURL?action=authenticate&token=6WX01471SY074580E")])
        )
        mockVaultAPI.stubSetupTokenResponse = updateSetupTokenResponse

        do {
            _ = try await sut.vault(vaultRequest)
            XCTFail("Invoked success() callback. Should invoke error().")
        } catch let error as CoreSDKError {
            XCTAssertEqual(error.code, CardClientError.threeDSecureURLError.code)
            XCTAssertEqual(error.domain, CardClientError.domain)
            XCTAssertEqual(error.localizedDescription, CardClientError.threeDSecureURLError.localizedDescription)
        }
    }

    func testVault_whenVaultAPIError_bubblesError() async throws {
        let setupTokenID = "testToken1"
        let vaultRequest = CardVaultRequest(card: card, setupTokenID: setupTokenID)

        mockVaultAPI.stubError = CoreSDKError(code: 123, domain: "fake-domain", errorDescription: "api-error")

        do {
            _ = try await sut.vault(vaultRequest)
            XCTFail("Invoked success() callback. Should invoke error().")
        } catch let error as CoreSDKError {
            XCTAssertEqual(error.domain, "fake-domain")
            XCTAssertEqual(error.code, 123)
            XCTAssertEqual(error.localizedDescription, "api-error")
        }
    }

    func testVault_whenUnknownError_returnsVaultError() async throws {
        let setupTokenID = "testToken1"
        let vaultRequest = CardVaultRequest(card: card, setupTokenID: setupTokenID)

        mockVaultAPI.stubError = NSError(domain: "some-domain", code: 123, userInfo: [NSLocalizedDescriptionKey: "some-description"])

        do {
            _ = try await sut.vault(vaultRequest)
            XCTFail("Invoked success() callback. Should invoke error().")
        } catch let error as CoreSDKError {
            XCTAssertEqual(error.domain, CardClientError.domain)
            XCTAssertEqual(error.code, CardClientError.Code.vaultTokenError.rawValue)
            XCTAssertEqual(error.localizedDescription, "An error occurred while vaulting a card.")
        }
    }

    func test_vault_withThreeDSecure_browserSwitchLaunches_vaultReturnsSuccess() async throws {
        mockVaultAPI.stubSetupTokenResponse = FakeUpdateSetupTokenResponse.withValid3DSURL

        mockWebAuthSession.cannedResponseURL = .init(string: "sdk.ios.paypal://vault/success")

        do {
            let result = try await sut.vault(cardVaultRequest)
            XCTAssertEqual(result.setupTokenID, "testSetupTokenId")
            XCTAssertNil(result.status)
            XCTAssertTrue(result.didAttemptThreeDSecureAuthentication)
        } catch {
            XCTFail("Invoked error() callback. Should invoke success().")
        }
    }

    func testVault_withThreeDSecure_userCancelsBrowser() async throws {
        mockVaultAPI.stubSetupTokenResponse = FakeUpdateSetupTokenResponse.withValid3DSURL

        mockWebAuthSession.cannedErrorResponse = ASWebAuthenticationSessionError(
            .canceledLogin,
            userInfo: ["Description": "Mock cancellation error description."]
        )

        do {
            _ = try await sut.vault(cardVaultRequest)
            XCTFail("Invoked success() callback. Should invoke error().")
        } catch let error as CoreSDKError {
            XCTAssertEqual(error.domain, CardClientError.domain)
            XCTAssertEqual(error.code, CardClientError.Code.threeDSCancellation.rawValue)
            XCTAssertEqual(error.localizedDescription, "3DS verification has been cancelled by the user.")
        }
    }

    func testVault_withThreeDSecure_browserReturnsError() async throws {
        mockVaultAPI.stubSetupTokenResponse = FakeUpdateSetupTokenResponse.withValid3DSURL

        mockWebAuthSession.cannedErrorResponse = CoreSDKError(
            code: CardClientError.Code.threeDSecureError.rawValue,
            domain: CardClientError.domain,
            errorDescription: "Mock web session error description."
        )

        do {
            _ = try await sut.vault(cardVaultRequest)
            XCTFail("Invoked success() callback. Should invoke error().")
        } catch let error as CoreSDKError {
            XCTAssertEqual(error.domain, CardClientError.domain)
            XCTAssertEqual(error.code, CardClientError.Code.threeDSecureError.rawValue)
            XCTAssertEqual(error.localizedDescription, "Mock web session error description.")
        }
    }

    // MARK: - approveOrder() tests

    func testAsyncApproveOrder_withInvalid3DSURL_returnsError() async throws {
        mockCheckoutOrdersAPI.stubConfirmResponse = FakeConfirmPaymentResponse.withInvalid3DSURL

        do {
            _ = try await sut.approveOrder(request: cardRequest)
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
            let result = try await sut.approveOrder(request: cardRequest)
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
            _ = try await sut.approveOrder(request: cardRequest)
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
            _ = try await sut.approveOrder(request: cardRequest)
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
            let result = try await sut.approveOrder(request: cardRequest)
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
            _ = try await sut.approveOrder(request: cardRequest)
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
            _ = try await sut.approveOrder(request: cardRequest)
            XCTFail("Invoked success() callback. Should invoke error().")
        } catch let error as CoreSDKError {
            XCTAssertEqual(error.domain, CardClientError.domain)
            XCTAssertEqual(error.code, CardClientError.Code.threeDSecureError.rawValue)
            XCTAssertNotNil(error.localizedDescription)
        }
    }
}
