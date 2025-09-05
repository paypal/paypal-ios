import XCTest
@testable import CorePayments
@testable import TestShared

class AuthenticationSecureTokenServiceAPI_Tests: XCTestCase {

    // MARK: - Helper Properties

    var sut: AuthenticationSecureTokenServiceAPI!
    var mockNetworkingClient: MockNetworkingClient!
    var coreConfig = CoreConfig(clientID: "fake-client-id", environment: .sandbox)

    // MARK: - Test lifecycle

    override func setUp() {
        super.setUp()

        mockNetworkingClient = MockNetworkingClient(coreConfig: coreConfig)
        sut = AuthenticationSecureTokenServiceAPI(coreConfig: coreConfig, networkingClient: mockNetworkingClient)
    }

    // MARK: - Tests

    func testCreateLowScopedAccessToken_UsesFormURLEncodedContentType() async throws {

        let responseBodyString = """
        {
            "access_token": "mock-token",
            "token_type": "Bearer"
        }
        """

        let responseBody = responseBodyString.data(using: .utf8)

        mockNetworkingClient.stubHTTPResponse = HTTPResponse(status: 200, body: responseBody)

        _ = try await sut.createLowScopedAccessToken()

        guard let capturedRequest = mockNetworkingClient.capturedRESTRequest else {
            XCTFail("No REST request was captured")
            return
        }

        XCTAssertEqual(capturedRequest.path, "v1/oauth2/token")
        XCTAssertEqual(capturedRequest.method, .post)
        XCTAssertEqual(capturedRequest.contentType, .formURLEncoded)
        if let postParams = capturedRequest.postParameters as? String {
            XCTAssertEqual(postParams, "grant_type=client_credentials&response_type=token")
        } else {
            XCTFail("Post parameters should be a String for form-urlencoded requests")
        }
    }
}
