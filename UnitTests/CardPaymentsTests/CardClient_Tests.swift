import XCTest
import SwiftUI
import AuthenticationServices
@testable import CorePayments
@testable import CardPayments
@testable import TestShared

// swiftlint:disable type_body_length
// swiftlint:disable file_length
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

    func testVault_withValidResponse_returnsSuccess() {
        let setupTokenID = "testToken1"
        let vaultStatus = "APPROVED"
        let vaultRequest = CardVaultRequest(card: card, setupTokenID: setupTokenID)
        let updateSetupTokenResponse = UpdateSetupTokenResponse(
            updateVaultSetupToken: TokenDetails(id: setupTokenID, status: vaultStatus, links: [TokenDetails.Link(rel: "df", href: "h")])
        )
        mockVaultAPI.stubSetupTokenResponse = updateSetupTokenResponse
        
        let expectation = expectation(description: "vault completed")

        sut.vault(vaultRequest) { result in
            switch result {
            case .success(let cardVaultResult):
                XCTAssertEqual(cardVaultResult.setupTokenID, setupTokenID)
                XCTAssertEqual(cardVaultResult.status, vaultStatus)
            case .failure:
                XCTFail("Expected success with CardVaultResult")
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
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
        sut.vault(vaultRequest) { result in
            switch result {
            case .success(let cardVaultResult):
                XCTAssertEqual(cardVaultResult.setupTokenID, setupTokenID)
                XCTAssertNil(cardVaultResult.status)
                XCTAssertTrue(cardVaultResult.didAttemptThreeDSecureAuthentication)
            case .failure:
                XCTFail("Expected success with CardVaultResult")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testVault_withInvalid3DSURLResponse_returnsError() {
        let setupTokenID = "testToken1"
        let vaultStatus = "PAYER_ACTION_REQUIRED"
        let vaultRequest = CardVaultRequest(card: card, setupTokenID: setupTokenID)
        let updateSetupTokenResponse = UpdateSetupTokenResponse(
            updateVaultSetupToken: TokenDetails(id: setupTokenID, status: vaultStatus, links: [TokenDetails.Link(rel: "approve", href: "https://www.sandbox.paypal.com/webapps/testBadURL?action=authenticate&token=6WX01471SY074580E")])
        )
        mockVaultAPI.stubSetupTokenResponse = updateSetupTokenResponse

        let expectation = expectation(description: "vault completed")

        sut.vault(vaultRequest) { result in
            switch result {
            case .success:
                XCTFail("Expected failure with error")
            case .failure(let error):
                XCTAssertEqual(error.domain, CardError.domain)
                XCTAssertEqual(error.code, CardError.threeDSecureURLError.code)
                XCTAssertEqual(error.localizedDescription, CardError.threeDSecureURLError.localizedDescription)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testVault_whenVaultAPIError_bubblesError() {
        let setupTokenID = "testToken1"
        let vaultRequest = CardVaultRequest(card: card, setupTokenID: setupTokenID)

        mockVaultAPI.stubError = CoreSDKError(code: 123, domain: "fake-domain", errorDescription: "api-error")

        let expectation = expectation(description: "vault completed")

        sut.vault(vaultRequest) { result in
            switch result {
            case .success:
                XCTFail("Expected failure with error")
            case .failure(let error):
                XCTAssertEqual(error.domain, "fake-domain")
                XCTAssertEqual(error.code, 123)
                XCTAssertEqual(error.localizedDescription, "api-error")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testVault_whenUnknownError_returnsVaultError() {
        let setupTokenID = "testToken1"
        let vaultRequest = CardVaultRequest(card: card, setupTokenID: setupTokenID)

        mockVaultAPI.stubError = NSError(domain: "some-domain", code: 123, userInfo: [NSLocalizedDescriptionKey: "some-description"])

        let expectation = expectation(description: "vault completed")
        sut.vault(vaultRequest) { result in
            switch result {
            case .success:
                XCTFail("Expected failure with error")
            case .failure(let error):
                XCTAssertEqual(error.domain, CardError.domain)
                XCTAssertEqual(error.code, CardError.Code.vaultTokenError.rawValue)
                XCTAssertEqual(error.localizedDescription, "An error occurred while vaulting a card.")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func test_vault_withThreeDSecure_browserSwitchLaunches_vaultReturnsSuccess() {
        mockVaultAPI.stubSetupTokenResponse = FakeUpdateSetupTokenResponse.withValid3DSURL

        mockWebAuthSession.cannedResponseURL = .init(string: "sdk.ios.paypal://vault/success")

        let expectation = expectation(description: "vault() completed")

        sut.vault(cardVaultRequest) { result in
            switch result {
            case .success(let cardVaultResult):
                XCTAssertEqual(cardVaultResult.setupTokenID, "testSetupTokenId")
                XCTAssertNil(cardVaultResult.status)
                XCTAssertTrue(cardVaultResult.didAttemptThreeDSecureAuthentication)
            case .failure:
                XCTFail("Expected success with CardVaultResult")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testVault_withThreeDSecure_userCancelsBrowser() {
        mockVaultAPI.stubSetupTokenResponse = FakeUpdateSetupTokenResponse.withValid3DSURL

        mockWebAuthSession.cannedErrorResponse = ASWebAuthenticationSessionError(
            .canceledLogin,
            userInfo: ["Description": "Mock cancellation error description."]
        )

        let expectation = expectation(description: "vault() completed")

        sut.vault(cardVaultRequest) { result in
            switch result {
            case .success:
                XCTFail("Expected failure with error")
            case .failure(let error):
                XCTAssertEqual(error.domain, CardError.domain)
                XCTAssertEqual(error.code, CardError.Code.threeDSecureCanceledError.rawValue)
                XCTAssertEqual(error.localizedDescription, CardError.threeDSecureCanceledError.localizedDescription)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testVault_withThreeDSecure_browserReturnsError() {
        mockVaultAPI.stubSetupTokenResponse = FakeUpdateSetupTokenResponse.withValid3DSURL

        mockWebAuthSession.cannedErrorResponse = CoreSDKError(
            code: CardError.Code.threeDSecureError.rawValue,
            domain: CardError.domain,
            errorDescription: "Mock web session error description."
        )

        let expectation = expectation(description: "vault() completed")

        sut.vault(cardVaultRequest) { result in
            switch result {
            case .success:
                XCTFail("Expected failure with error")
            case .failure(let error):
                XCTAssertEqual(error.domain, CardError.domain)
                XCTAssertEqual(error.code, CardError.Code.threeDSecureError.rawValue)
                XCTAssertEqual(error.localizedDescription, "Mock web session error description.")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    // MARK: - approveOrder() tests

    func testApproveOrder_withInvalid3DSURL_returnsError() {
        mockCheckoutOrdersAPI.stubConfirmResponse = FakeConfirmPaymentResponse.withInvalid3DSURL
        
        let expectation = expectation(description: "approveOrder() completed")

        sut.approveOrder(request: cardRequest) { result in
            switch result {
            case .success:
                XCTFail("Expected failure with error")
            case .failure(let error):
                XCTAssertEqual(error.code, 3)
                XCTAssertEqual(error.domain, "CardClientErrorDomain")
                XCTAssertEqual(error.errorDescription, "An invalid 3DS URL was returned. Contact developer.paypal.com/support.")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testApproveOrder_withNoThreeDSecure_returnsOrderData() {
        mockCheckoutOrdersAPI.stubConfirmResponse = FakeConfirmPaymentResponse.without3DS
        let expectation = expectation(description: "approveOrder() completed")

        sut.approveOrder(request: cardRequest) { result in
            switch result {
            case .success(let cardResult):
                XCTAssertEqual(cardResult.orderID, "testOrderId")
                XCTAssertEqual(cardResult.status, "APPROVED")
                XCTAssertFalse(cardResult.didAttemptThreeDSecureAuthentication)
            case .failure:
                XCTFail("Expected success with CardResult")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testApproveOrder_whenConfirmPaymentSDKError_bubblesError() {
        mockCheckoutOrdersAPI.stubError = CoreSDKError(code: 123, domain: "sdk-domain", errorDescription: "sdk-error-desc")

        let expectation = expectation(description: "approveOrder() completed")

        sut.approveOrder(request: cardRequest) { result in
            switch result {
            case .success:
                XCTFail("Expected failure with error")
            case .failure(let error):
                XCTAssertEqual(error.code, 123)
                XCTAssertEqual(error.domain, "sdk-domain")
                XCTAssertEqual(error.errorDescription, "sdk-error-desc")
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testApproveOrder_whenConfirmPaymentGeneralError_returnsUnknownError() {
        mockCheckoutOrdersAPI.stubError = NSError(
            domain: "ns-fake-domain",
            code: 123,
            userInfo: [NSLocalizedDescriptionKey: "ns-fake-error"]
        )

        let expectation = expectation(description: "approveOrder() completed")

        sut.approveOrder(request: cardRequest) { result in
            switch result {
            case .success:
                XCTFail("Expected failure with error")
            case .failure(let error):
                XCTAssertEqual(error.domain, CardError.domain)
                XCTAssertEqual(error.code, CardError.Code.unknown.rawValue)
                XCTAssertNotNil(error.localizedDescription)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testApproveOrder_withThreeDSecure_browserSwitchLaunches_getOrderReturnsSuccess() {
        mockCheckoutOrdersAPI.stubConfirmResponse = FakeConfirmPaymentResponse.withValid3DSURL

        mockWebAuthSession.cannedResponseURL = .init(string: "sdk.ios.paypal://card/success?state=undefined&code=undefined&liability_shift=POSSIBLE")
        let expectation = expectation(description: "approveOrder() completed")

        sut.approveOrder(request: cardRequest) { result in
            switch result {
            case .success(let cardResult):
                XCTAssertEqual(cardResult.orderID, "testOrderId")
                XCTAssertNil(cardResult.status)
                XCTAssertTrue(cardResult.didAttemptThreeDSecureAuthentication)
            case .failure:
                XCTFail("Expected success with CardResult")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testApproveOrder_withThreeDSecure_userCancelsBrowser() {
        mockCheckoutOrdersAPI.stubConfirmResponse = FakeConfirmPaymentResponse.withValid3DSURL

        mockWebAuthSession.cannedErrorResponse = ASWebAuthenticationSessionError(
            .canceledLogin,
            userInfo: ["Description": "Mock cancellation error description."]
        )

        let expectation = expectation(description: "approveOrder() completed")

        sut.approveOrder(request: cardRequest) { result in
            switch result {
            case .success:
                XCTFail("Expected failure with error")
            case .failure(let error):
                XCTAssertEqual(error.domain, CardError.domain)
                XCTAssertEqual(error.code, CardError.threeDSecureCanceledError.code)
                XCTAssertEqual(error.localizedDescription, CardError.threeDSecureCanceledError.localizedDescription)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testApproveOrder_withThreeDSecure_browserReturnsError() {
        mockCheckoutOrdersAPI.stubConfirmResponse = FakeConfirmPaymentResponse.withValid3DSURL

        mockWebAuthSession.cannedErrorResponse = CoreSDKError(
            code: CardError.Code.threeDSecureError.rawValue,
            domain: CardError.domain,
            errorDescription: "Mock web session error description."
        )

        let expectation = expectation(description: "approveOrder() completed")

        sut.approveOrder(request: cardRequest) { result in
            switch result {
            case .success:
                XCTFail("Expected failure with error")
            case .failure(let error):
                XCTAssertEqual(error.domain, CardError.domain)
                XCTAssertEqual(error.code, CardError.Code.threeDSecureError.rawValue)
                XCTAssertEqual(error.localizedDescription, "Mock web session error description.")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    // MARK: - Helper function test

    func testApproveOrder_withThreeDSecure_userCancelsBrowser_returns_isThreeDSecureCanceledTrue() {
        mockCheckoutOrdersAPI.stubConfirmResponse = FakeConfirmPaymentResponse.withValid3DSURL
        mockWebAuthSession.cannedErrorResponse = ASWebAuthenticationSessionError(
            .canceledLogin,
            userInfo: ["Description": "Mock cancellation error description."]
        )

        let expectation = expectation(description: "approveOrder() completed")

        sut.approveOrder(request: cardRequest) { result in
            switch result {
            case .success:
                XCTFail("Expected failure with cancellation error")
            case .failure(let error):
                XCTAssertTrue(CardError.isThreeDSecureCanceled(error))
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }
}
