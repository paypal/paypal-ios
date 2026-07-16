import XCTest
import AuthenticationServices
@testable import CorePayments
@testable import PayPalWebPayments
@testable import TestShared

// swiftlint:disable type_body_length file_length
class PayPalWebCheckoutClient_CreateSession_Tests: XCTestCase {

    // MARK: - Properties

    var config: CoreConfig!
    var payPalClient: PayPalWebCheckoutClient!
    var mockWebAuthenticationSession: MockWebAuthenticationSession!
    var mockNetworkingClient: MockNetworkingClient!
    var mockClientConfigAPI: MockClientConfigAPI!
    var mockPatchCCOAPI: MockPatchCCOAPI!
    var mockCreateShopperSessionAPI: MockCreateShopperSessionAPI!
    var mockURLOpener: MockURLOpener!

    let fakeURLConfig = PayPalURLConfig(
        returnAppURL: URL(string: "paypal://return")!,
        cancelAppURL: URL(string: "paypal://cancel")!,
        fallbackSchemeURL: URL(string: "paypal://fallback")!
    )

    /// Convenience factory: ineligible session with a valid session ID.
    func makeIneligibleSession(id: String = "fake-session-id") -> ShopperSessionResult {
        ShopperSessionResult(
            appSwitchEligibilityResponse: AppSwitchEligibilityResponse(
                appSwitchEligible: false,
                ineligibleReason: "TEST_INELIGIBLE",
                checkoutUrls: nil
            ),
            shopperSessionResponse: ShopperSessionResponse(
                sessionId: id,
                expiresAt: "2026-12-31T00:00:00Z"
            )
        )
    }

    /// Convenience factory: eligible session with a redirect URL and valid session ID.
    func makeEligibleSession(
        id: String = "fake-session-id",
        redirectURL: String = "https://paypal.com/app-switch"
    ) -> ShopperSessionResult {
        ShopperSessionResult(
            appSwitchEligibilityResponse: AppSwitchEligibilityResponse(
                appSwitchEligible: true,
                ineligibleReason: nil,
                checkoutUrls: CheckoutUrls(redirectURL: redirectURL, checkoutFallbackUrl: nil)
            ),
            shopperSessionResponse: ShopperSessionResponse(
                sessionId: id,
                expiresAt: "2026-12-31T00:00:00Z"
            )
        )
    }

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        config = CoreConfig(clientID: "testClientID", environment: .sandbox, merchantID: "testMerchantID")
        mockWebAuthenticationSession = MockWebAuthenticationSession()
        mockNetworkingClient = MockNetworkingClient(http: MockHTTP(coreConfig: config))
        mockClientConfigAPI = MockClientConfigAPI(coreConfig: config, networkingClient: mockNetworkingClient)
        mockPatchCCOAPI = MockPatchCCOAPI(coreConfig: config)
        mockCreateShopperSessionAPI = MockCreateShopperSessionAPI(coreConfig: config)
        mockURLOpener = MockURLOpener()

        payPalClient = PayPalWebCheckoutClient(
            config: config,
            networkingClient: mockNetworkingClient,
            clientConfigAPI: mockClientConfigAPI,
            patchCCOAPI: mockPatchCCOAPI,
            createShopperSessionAPI: mockCreateShopperSessionAPI,
            webAuthenticationSession: mockWebAuthenticationSession
        )
        // Defaults to `mockIsPayPalAppInstalled = false`, matching how `UIApplication.shared` behaves
        // in the test target (no `paypal://` query scheme entitlement) — but deterministically, and
        // overridable per-test for the app-switch fallback cases below.
        payPalClient.urlOpener = mockURLOpener
    }

    override func tearDown() {
        config = nil
        payPalClient = nil
        mockWebAuthenticationSession = nil
        mockNetworkingClient = nil
        mockClientConfigAPI = nil
        mockPatchCCOAPI = nil
        mockCreateShopperSessionAPI = nil
        mockURLOpener = nil
        super.tearDown()
    }

    // MARK: - Guard: sessionNotStarted

    func testStart_whenCreatePayPalSessionNotCalled_returnsSessionNotStartedError() {
        let expectation = expectation(description: "start returns sessionNotStartedError")

        payPalClient.start(orderID: "fake-order-id") { result in
            switch result {
            case .success:
                XCTFail("Expected failure")
            case .failure(let error):
                XCTAssertEqual(error.domain, PayPalError.domain)
                XCTAssertEqual(error.code, PayPalError.Code.sessionNotStarted.rawValue)
                XCTAssertEqual(
                    error.localizedDescription,
                    "createPayPalSession() must be called before start() or vault()."
                )
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testVault_whenCreatePayPalSessionNotCalled_returnsSessionNotStartedError() {
        let expectation = expectation(description: "vault returns sessionNotStartedError")

        payPalClient.vault(setupTokenID: "fake-setup-token") { result in
            switch result {
            case .success:
                XCTFail("Expected failure")
            case .failure(let error):
                XCTAssertEqual(error.domain, PayPalError.domain)
                XCTAssertEqual(error.code, PayPalError.Code.sessionNotStarted.rawValue)
                XCTAssertEqual(
                    error.localizedDescription,
                    "createPayPalSession() must be called before start() or vault()."
                )
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    // MARK: - Success flow

    func testCreatePayPalSession_whenSessionSucceeds_startProceedsToCheckout() {
        mockCreateShopperSessionAPI.stubResponse = makeIneligibleSession()
        mockClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: true)
        mockWebAuthenticationSession.cannedResponseURL = URL(
            string: "https://fakeURL?token=order-123&PayerID=payer-456"
        )

        payPalClient.createPayPalSession(urlConfig: fakeURLConfig)

        let expectation = expectation(description: "start succeeds after session")
        payPalClient.start(orderID: "order-123") { result in
            switch result {
            case .success(let checkoutResult):
                XCTAssertEqual(checkoutResult.orderID, "order-123")
                XCTAssertEqual(checkoutResult.payerID, "payer-456")
            case .failure(let error):
                XCTFail("Expected success, got error: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testCreatePayPalSession_whenSessionSucceeds_vaultProceedsToVault() {
        mockCreateShopperSessionAPI.stubResponse = makeIneligibleSession()
        mockWebAuthenticationSession.cannedResponseURL = URL(
            string: "sdk.ios.paypal://vault/success?approval_token_id=token-abc&approval_session_id=session-xyz"
        )

        payPalClient.createPayPalSession(urlConfig: fakeURLConfig)

        let expectation = expectation(description: "vault succeeds after session")
        payPalClient.vault(setupTokenID: "fake-setup-token") { result in
            switch result {
            case .success(let vaultResult):
                XCTAssertEqual(vaultResult.tokenID, "token-abc")
                XCTAssertEqual(vaultResult.approvalSessionID, "session-xyz")
            case .failure(let error):
                XCTFail("Expected success, got error: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    // MARK: - Session fetch failure
    //
    // A failed Shopper Session fetch no longer fails start()/vault() outright — it falls back to the
    // legacy PatchCCO app-switch-eligibility check, then to the web auth flow, so the outcome now
    // depends on that fallback rather than on the original session-fetch error (which is no longer
    // surfaced to the caller).

    func testCreatePayPalSession_whenSessionFetchFails_appNotInstalled_startFallsBackToWebCheckoutAndSucceeds() {
        mockCreateShopperSessionAPI.stubError = CoreSDKError(
            code: PayPalError.Code.unknown.rawValue,
            domain: PayPalError.domain,
            errorDescription: "Session fetch failed."
        )
        mockURLOpener.mockIsPayPalAppInstalled = false
        mockClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: true)
        mockWebAuthenticationSession.cannedResponseURL = URL(
            string: "https://fakeURL?token=order-123&PayerID=payer-456"
        )

        payPalClient.createPayPalSession(urlConfig: fakeURLConfig)

        let expectation = expectation(description: "start falls back to web checkout and succeeds")
        payPalClient.start(orderID: "order-123") { result in
            switch result {
            case .success(let checkoutResult):
                XCTAssertEqual(checkoutResult.orderID, "order-123")
                XCTAssertEqual(checkoutResult.payerID, "payer-456")
            case .failure(let error):
                XCTFail("Expected fallback to web checkout to succeed, got: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testCreatePayPalSession_whenSessionFetchFails_appNotInstalled_startFallsBackToWebCheckoutAndFails() {
        mockCreateShopperSessionAPI.stubError = CoreSDKError(
            code: PayPalError.Code.unknown.rawValue,
            domain: PayPalError.domain,
            errorDescription: "Session fetch failed."
        )
        mockURLOpener.mockIsPayPalAppInstalled = false
        mockWebAuthenticationSession.cannedResponseURL = URL(string: "https://fakeURL?opType=cancel")

        payPalClient.createPayPalSession(urlConfig: fakeURLConfig)

        let expectation = expectation(description: "start falls back to web checkout and fails")
        payPalClient.start(orderID: "order-123") { result in
            switch result {
            case .success:
                XCTFail("Expected failure")
            case .failure(let error):
                // The fallback's own web checkout outcome (canceled here) is what's surfaced now —
                // not the original "Session fetch failed." error.
                XCTAssertEqual(error.domain, PayPalError.domain)
                XCTAssertEqual(error.code, PayPalError.Code.checkoutCanceledError.rawValue)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testCreatePayPalSession_whenSessionFetchFails_appInstalledAndEligible_startAttemptsAppSwitch() {
        mockCreateShopperSessionAPI.stubError = CoreSDKError(
            code: PayPalError.Code.unknown.rawValue,
            domain: PayPalError.domain,
            errorDescription: "Session fetch failed."
        )
        mockURLOpener.mockIsPayPalAppInstalled = true
        mockURLOpener.mockOpenURLSuccess = true
        mockPatchCCOAPI.stubEligibilityResponse = AppSwitchEligibility(
            appSwitchEligible: true,
            redirectURL: "https://sandbox.paypal.com/app-switch-checkout?token=order-123",
            ineligibleReason: nil
        )

        payPalClient.createPayPalSession(urlConfig: fakeURLConfig)

        let urlOpenedExpectation = expectation(description: "app switch URL opened")
        mockURLOpener.didOpenURLHandler = { urlOpenedExpectation.fulfill() }

        let completionExpectation = expectation(description: "start completes after handleReturnURL")
        payPalClient.start(orderID: "order-123") { result in
            if case .success(let checkoutResult) = result {
                XCTAssertEqual(checkoutResult.orderID, "order-123")
                XCTAssertEqual(checkoutResult.payerID, "payer-456")
            } else {
                XCTFail("Expected success via app switch")
            }
            completionExpectation.fulfill()
        }

        wait(for: [urlOpenedExpectation], timeout: 2)
        XCTAssertNil(mockWebAuthenticationSession.lastLaunchedURL)

        payPalClient.handleReturnURL(URL(string: "https://appswitch.com/success?token=order-123&PayerID=payer-456")!)
        wait(for: [completionExpectation], timeout: 2)
    }

    func testCreatePayPalSession_whenSessionFetchFails_appNotInstalled_vaultFallsBackToWebAuthAndSucceeds() {
        mockCreateShopperSessionAPI.stubError = CoreSDKError(
            code: PayPalError.Code.unknown.rawValue,
            domain: PayPalError.domain,
            errorDescription: "Session fetch failed."
        )
        mockURLOpener.mockIsPayPalAppInstalled = false
        mockWebAuthenticationSession.cannedResponseURL = URL(
            string: "sdk.ios.paypal://vault/success?approval_token_id=token-abc&approval_session_id=session-xyz"
        )

        payPalClient.createPayPalSession(urlConfig: fakeURLConfig)

        let expectation = expectation(description: "vault falls back to web auth and succeeds")
        payPalClient.vault(setupTokenID: "fake-setup-token") { result in
            switch result {
            case .success(let vaultResult):
                XCTAssertEqual(vaultResult.tokenID, "token-abc")
                XCTAssertEqual(vaultResult.approvalSessionID, "session-xyz")
            case .failure(let error):
                XCTFail("Expected fallback to web auth to succeed, got: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testCreatePayPalSession_whenSessionFetchFails_appNotInstalled_vaultFallsBackToWebAuthAndFails() {
        mockCreateShopperSessionAPI.stubError = CoreSDKError(
            code: PayPalError.Code.unknown.rawValue,
            domain: PayPalError.domain,
            errorDescription: "Session fetch failed."
        )
        mockURLOpener.mockIsPayPalAppInstalled = false
        mockWebAuthenticationSession.cannedResponseURL = URL(string: "https://fakeURL/cancel")

        payPalClient.createPayPalSession(urlConfig: fakeURLConfig)

        let expectation = expectation(description: "vault falls back to web auth and fails")
        payPalClient.vault(setupTokenID: "fake-setup-token") { result in
            switch result {
            case .success:
                XCTFail("Expected failure")
            case .failure(let error):
                // The fallback's own web auth outcome (canceled here) is what's surfaced now —
                // not the original "Session fetch failed." error.
                XCTAssertEqual(error.domain, PayPalError.domain)
                XCTAssertEqual(error.code, PayPalError.Code.vaultCanceledError.rawValue)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testCreatePayPalSession_whenSessionFetchFails_appInstalledAndEligible_vaultAttemptsAppSwitch() {
        mockCreateShopperSessionAPI.stubError = CoreSDKError(
            code: PayPalError.Code.unknown.rawValue,
            domain: PayPalError.domain,
            errorDescription: "Session fetch failed."
        )
        mockURLOpener.mockIsPayPalAppInstalled = true
        mockURLOpener.mockOpenURLSuccess = true
        mockPatchCCOAPI.stubEligibilityResponse = AppSwitchEligibility(
            appSwitchEligible: true,
            redirectURL: "https://sandbox.paypal.com/app-switch-vault?approval_session_id=fake-setup-token",
            ineligibleReason: nil
        )

        payPalClient.createPayPalSession(urlConfig: fakeURLConfig)

        let urlOpenedExpectation = expectation(description: "app switch URL opened")
        mockURLOpener.didOpenURLHandler = { urlOpenedExpectation.fulfill() }

        let completionExpectation = expectation(description: "vault completes after handleReturnURL")
        payPalClient.vault(setupTokenID: "fake-setup-token") { result in
            if case .success(let vaultResult) = result {
                XCTAssertEqual(vaultResult.tokenID, "token-abc")
                XCTAssertEqual(vaultResult.approvalSessionID, "session-xyz")
            } else {
                XCTFail("Expected success via app switch")
            }
            completionExpectation.fulfill()
        }

        wait(for: [urlOpenedExpectation], timeout: 2)
        XCTAssertNil(mockWebAuthenticationSession.lastLaunchedURL)

        payPalClient.handleReturnURL(
            URL(string: "https://appswitch.com/success?approval_token_id=token-abc&approval_session_id=session-xyz")!
        )
        wait(for: [completionExpectation], timeout: 2)
    }

    // MARK: - Response fields

    func testCreatePayPalSession_responseContainsAppSwitchEligibleTrue() {
        let session = makeEligibleSession(redirectURL: "https://sandbox.paypal.com/app-switch-checkout")
        XCTAssertTrue(session.appSwitchEligible)
        XCTAssertEqual(session.redirectURL, "https://sandbox.paypal.com/app-switch-checkout")
        XCTAssertNil(session.ineligibleReason)
        XCTAssertNotNil(session.shopperSessionConfig)
        XCTAssertEqual(session.shopperSessionConfig?.id, "fake-session-id")
        XCTAssertEqual(session.shopperSessionConfig?.expiresAt, "2026-12-31T00:00:00Z")
    }

    func testCreatePayPalSession_responseContainsAppSwitchEligibleFalse() {
        let session = makeIneligibleSession()
        XCTAssertFalse(session.appSwitchEligible)
        XCTAssertNil(session.redirectURL)
        XCTAssertEqual(session.ineligibleReason, "TEST_INELIGIBLE")
        XCTAssertNotNil(session.shopperSessionConfig)
    }

    // MARK: - Parameter forwarding

    func testCreatePayPalSession_passesURLConfigToAPI() {
        mockCreateShopperSessionAPI.stubResponse = makeIneligibleSession()
        let urlConfig = PayPalURLConfig(
            returnAppURL: URL(string: "myapp://paypal/return")!,
            cancelAppURL: URL(string: "myapp://paypal/cancel")!,
            fallbackSchemeURL: URL(string: "myapp://fallback")!
        )

        payPalClient.createPayPalSession(urlConfig: urlConfig)

        let expectation = expectation(description: "session task runs")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(
                self.mockCreateShopperSessionAPI.capturedURLConfig?.returnAppURL.absoluteString,
                "myapp://paypal/return"
            )
            XCTAssertEqual(
                self.mockCreateShopperSessionAPI.capturedURLConfig?.cancelAppURL.absoluteString,
                "myapp://paypal/cancel"
            )
            XCTAssertEqual(
                self.mockCreateShopperSessionAPI.capturedURLConfig?.fallbackSchemeURL?.absoluteString,
                "myapp://fallback"
            )
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testCreatePayPalSession_passesUserIdentityToAPI() {
        mockCreateShopperSessionAPI.stubResponse = makeIneligibleSession()

        payPalClient.createPayPalSession(
            userIdentity: .init(email: "buyer@example.com", phone: nil),
            urlConfig: fakeURLConfig
        )

        let expectation = expectation(description: "session task runs")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let email = self.mockCreateShopperSessionAPI.capturedUserIdentity?.email
            XCTAssertEqual(email, "buyer@example.com")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testCreatePayPalSession_defaultUserIdentity_isNil() {
        mockCreateShopperSessionAPI.stubResponse = makeIneligibleSession()

        payPalClient.createPayPalSession(urlConfig: fakeURLConfig)

        let expectation = expectation(description: "session task runs")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertNil(self.mockCreateShopperSessionAPI.capturedUserIdentity)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    // MARK: - sessionTask lifecycle

    func testStart_clearsSessionTask_afterCheckoutSucceeds() {
        mockCreateShopperSessionAPI.stubResponse = makeIneligibleSession()
        mockClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: true)
        mockWebAuthenticationSession.cannedResponseURL = URL(
            string: "https://fakeURL?token=order-123&PayerID=payer-456"
        )

        payPalClient.createPayPalSession(urlConfig: fakeURLConfig)

        let firstStart = expectation(description: "first start completes")
        payPalClient.start(orderID: "order-123") { _ in firstStart.fulfill() }
        wait(for: [firstStart], timeout: 2)

        // sessionTask should be cleared — second start without a new session returns sessionNotStarted
        let secondStart = expectation(description: "second start returns sessionNotStartedError")
        payPalClient.start(orderID: "order-123") { result in
            if case .failure(let error) = result {
                XCTAssertEqual(error.code, PayPalError.Code.sessionNotStarted.rawValue)
            } else {
                XCTFail("Expected sessionNotStarted error")
            }
            secondStart.fulfill()
        }
        wait(for: [secondStart], timeout: 1)
    }

    func testStart_clearsSessionTask_afterSessionFetchFails() {
        mockCreateShopperSessionAPI.stubError = CoreSDKError(
            code: 0, domain: "test", errorDescription: "fetch failed"
        )
        // Session fetch failure now falls back to the web checkout flow (app not installed, per
        // mockURLOpener's default) rather than failing immediately, so the fallback needs its own
        // deterministic outcome for `firstStart`'s completion to fire at all.
        mockWebAuthenticationSession.cannedResponseURL = URL(string: "https://fakeURL?opType=cancel")

        payPalClient.createPayPalSession(urlConfig: fakeURLConfig)

        let firstStart = expectation(description: "first start completes with error")
        payPalClient.start(orderID: "order-123") { _ in firstStart.fulfill() }
        wait(for: [firstStart], timeout: 2)

        // sessionTask should be cleared
        let secondStart = expectation(description: "second start returns sessionNotStartedError")
        payPalClient.start(orderID: "order-123") { result in
            if case .failure(let error) = result {
                XCTAssertEqual(error.code, PayPalError.Code.sessionNotStarted.rawValue)
            } else {
                XCTFail("Expected sessionNotStarted error")
            }
            secondStart.fulfill()
        }
        wait(for: [secondStart], timeout: 1)
    }

    func testVault_clearsSessionTask_afterVaultSucceeds() {
        mockCreateShopperSessionAPI.stubResponse = makeIneligibleSession()
        mockWebAuthenticationSession.cannedResponseURL = URL(
            string: "sdk.ios.paypal://vault/success?approval_token_id=token-abc&approval_session_id=session-xyz"
        )

        payPalClient.createPayPalSession(urlConfig: fakeURLConfig)

        let firstVault = expectation(description: "first vault completes")
        payPalClient.vault(setupTokenID: "fake-setup-token") { _ in firstVault.fulfill() }
        wait(for: [firstVault], timeout: 2)

        // sessionTask should be cleared
        let secondVault = expectation(description: "second vault returns sessionNotStartedError")
        payPalClient.vault(setupTokenID: "fake-setup-token") { result in
            if case .failure(let error) = result {
                XCTAssertEqual(error.code, PayPalError.Code.sessionNotStarted.rawValue)
            } else {
                XCTFail("Expected sessionNotStarted error")
            }
            secondVault.fulfill()
        }
        wait(for: [secondVault], timeout: 1)
    }

    // MARK: - Calling createPayPalSession twice

    func testCreatePayPalSession_calledTwice_secondSessionIsUsedByStart() {
        // First call fails, second succeeds — start should use the second session.
        mockCreateShopperSessionAPI.stubError = CoreSDKError(
            code: 0, domain: "test", errorDescription: "first session error"
        )
        payPalClient.createPayPalSession(urlConfig: fakeURLConfig)

        // Override stub so second call succeeds
        mockCreateShopperSessionAPI.stubError = nil
        mockCreateShopperSessionAPI.stubResponse = makeIneligibleSession()
        mockClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: true)
        mockWebAuthenticationSession.cannedResponseURL = URL(
            string: "https://fakeURL?token=order-123&PayerID=payer-456"
        )
        payPalClient.createPayPalSession(urlConfig: fakeURLConfig)

        let expectation = expectation(description: "start succeeds using second session")
        payPalClient.start(orderID: "order-123") { result in
            switch result {
            case .success(let checkoutResult):
                XCTAssertEqual(checkoutResult.orderID, "order-123")
            case .failure(let error):
                XCTFail("Expected success, got: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testCreatePayPalSession_calledTwice_apiCallCountIsAtLeastOne() {
        mockCreateShopperSessionAPI.stubResponse = makeIneligibleSession()

        payPalClient.createPayPalSession(urlConfig: fakeURLConfig)
        payPalClient.createPayPalSession(urlConfig: fakeURLConfig)

        let expectation = expectation(description: "tasks run")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertGreaterThanOrEqual(self.mockCreateShopperSessionAPI.callCount, 1)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }
}
// swiftlint:enable type_body_length file_length
