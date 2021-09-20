import Foundation

protocol MockRequestResponse {

    var responseData: Data? { get }

    func canHandle(request: URLRequest) -> Bool
    func response(for request: URLRequest) -> HTTPURLResponse
}

class MockAccessTokenRequestResponse: MockRequestResponse {

    static let mockSuccessResponse: String = """
    {
      "scope": "https://uri.paypal.com/services/invoicing https://uri.paypal.com/services/payments/futurepayments https://uri.paypal.com/services/identity/document-verifications/readwrite https://uri.paypal.com/services/apis/history/api-calls https://uri.paypal.com/services/identity/users/profile/view https://uri.paypal.com/services/referred-disputes/readwrite https://uri.paypal.com/services/identity/applications/classic-credentials/view https://uri.paypal.com/customer/account/testaccount https://uri.paypal.com/services/tickets/read https://api.paypal.com/v1/vault/credit-card https://uri.paypal.com/services/location/address-normalization/address-suggest https://api.paypal.com/v1/payments/.* https://uri.paypal.com/services/identity/users/intents/admin https://uri.paypal.com/services/payments/payment https://uri.paypal.com/services/customer/onboarding/admin https://uri.paypal.com/services/payments/channelpartner https://uri.paypal.com/services/personalization/message-recommendations/credit-cache/flush https://uri.paypal.com/services/risk/identity-verification-results/readwrite https://uri.paypal.com/services/applications/webhooks https://uri.paypal.com/services/identity/document-verifications/verify/readwrite https://uri.paypal.com/services/security/dukpt-trsm-types/initial-keys-derive https://uri.paypal.com/services/marketplaces/billing-agreements/read https://uri.paypal.com/services/location/address-normalization/address-verify https://uri.paypal.com/services/security/dukpt-trsm-types/pinblock-translate https://api.paypal.com/v1/developer/.* https://uri.paypal.com/services/personalization/message-recommendations/read https://uri.paypal.com/services/marketplaces/users/read https://uri.paypal.com/services/customer/onboarding/partner openid https://uri.paypal.com/services/security/dukpt-trsm-types/decrypt https://uri.paypal.com/services/marketplaces/transactions/read https://uri.paypal.com/services/identity/users/intents https://uri.paypal.com/services/risk/identity-verifications/readwrite https://uri.paypal.com/services/risk/raas/transaction-context https://uri.paypal.com/services/identity/document-verifications/read https://uri.paypal.com/services/credit/messages/read https://uri.paypal.com/services/security/zones/fail-over-key https://uri.paypal.com/services/customer/onboarding/applications https://uri.paypal.com/services/identity/proxyclient https://uri.paypal.com/services/marketplaces/off-platform-transactions/read https://uri.paypal.com/services/identity/credential-availability-check https://uri.paypal.com/services/marketplaces/payouts/read https://api.paypal.com/v1/vault/credit-card/.* https://uri.paypal.com/services/subscriptions https://uri.paypal.com/services/customer/onboarding/eligibility https://uri.paypal.com/services/tickets/readwrite",
      "access_token": "TestToken",
      "token_type": "Bearer",
      "expires_in": 29688,
      "nonce": "2021-09-13T15:00:23ZLpaHBzwLdATlXfE-G4NJsoxi9jPsYuMzOIE4u1TqDx8"
    }
    """

    static let mockFailureResponse: String = """
    {
        "error": "unsupported_grant_type",
        "error_description": "unsupported grant_type"
    }
    """

    static let mockInvalidResponse: String = """
    {
        "test": "wrong response format"
    }
    """

    var responseString: String?
    var statusCode: Int

    init(responseString: String?, statusCode: Int) {
        self.responseString = responseString
        self.statusCode = statusCode
    }

    var responseData: Data? {
        return responseString?.data(using: .utf8)
    }
    
    func canHandle(request: URLRequest) -> Bool {
        guard let url = request.url, url.path == "/v1/oauth2/token" else {
            return false
        }
        return true
    }
    
    func response(for request: URLRequest) -> HTTPURLResponse {
        guard let url = request.url else {
            fatalError("No URL for request")
        }
        return HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: [:]) ?? HTTPURLResponse()
    }
}
