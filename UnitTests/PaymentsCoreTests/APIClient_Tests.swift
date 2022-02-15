import XCTest
@testable import PaymentsCore
@testable import TestShared

class APIClient_Tests: XCTestCase {

    // MARK: - Helper Properties

    // swiftlint:disable:next force_unwrapping
    let successURLResponse = HTTPURLResponse(url: URL(string: "www.test.com")!, statusCode: 200, httpVersion: "https", headerFields: [:])
    let config = CoreConfig(clientID: "", environment: .sandbox)
    let fakeRequest = FakeRequest()

    // swiftlint:disable implicitly_unwrapped_optional
    var mockURLSession: MockURLSession!
    var apiClient: APIClient!
    // swiftlint:enable implicitly_unwrapped_optional

    // MARK: - Test lifecycle

    override func setUp() {
        super.setUp()

        mockURLSession = MockURLSession()
        mockURLSession.cannedError = nil
        mockURLSession.cannedURLResponse = nil
        mockURLSession.cannedJSONData = nil

        apiClient = APIClient(urlSession: mockURLSession, environment: .sandbox)
    }

    func testInit_whenEnvironmentProvided_returnCorrectEnvironment() {
        let apiClientAux = APIClient(environment: .sandbox)
        XCTAssertEqual(apiClientAux.environment, .sandbox)
    }
    // MARK: - fetch() tests

    // TODO: This test is specific to AccessToken, move it out of this file.
    func testFetch_whenAccessTokenSuccessResponse_returnsValidAccessToken() async {
        let jsonResponse = """
        {
            "scope": "fake-scope",
            "access_token": "fake-token",
            "token_type": "fake-bearer",
            "expires_in": 1,
            "nonce": "fake-nonce"
        }
        """

        mockURLSession.cannedURLResponse = successURLResponse
        mockURLSession.cannedJSONData = jsonResponse

        let accessTokenRequest = AccessTokenRequest(clientID: "")
        do {
            let (result, _) = try await apiClient.fetch(endpoint: accessTokenRequest)
            XCTAssertEqual(result.accessToken, "fake-token")
            XCTAssertEqual(result.nonce, "fake-nonce")
            XCTAssertEqual(result.scope, "fake-scope")
            XCTAssertEqual(result.tokenType, "fake-bearer")
            XCTAssertEqual(result.expiresIn, 1)
        } catch {
            XCTFail("Expect success response")
        }
    }

    func testFetch_withNoURLRequest_returnsInvalidURLRequestError() async {
        // Mock request whose API object does not vend a URLRequest
        let noURLRequest = FakeRequestNoURL()

        do {
            _ = try await apiClient.fetch(endpoint: noURLRequest)
            XCTFail("This should have failed.")
        } catch let error as PayPalSDKError {
            XCTAssertEqual(error.domain, APIClientError.domain)
            XCTAssertEqual(error.code, APIClientError.Code.invalidURLRequest.rawValue)
            XCTAssertEqual(error.localizedDescription, "An error occured constructing an HTTP request. Contact developer.paypal.com/support.")
        } catch {
            XCTFail("Unexpected error type")
        }
    }

    func testFetch_whenServerError_returnsURLSessionError() async {
        let serverError = NSError(
            domain: URLError.errorDomain,
            code: NSURLErrorBadServerResponse,
            userInfo: [NSLocalizedDescriptionKey: "fake-error"]
        )

        mockURLSession.cannedError = serverError

        do {
            _ = try await apiClient.fetch(endpoint: fakeRequest)
            XCTFail()
        } catch let error {
            XCTAssertTrue(serverError === (error as AnyObject))
        }
    }

    func testFetch_whenInvalidData_returnsParseError() async {
        mockURLSession.cannedURLResponse = successURLResponse
        mockURLSession.cannedJSONData = "{ \"test\" : \"bad-format\" }"

        do {
            _ = try await apiClient.fetch(endpoint: fakeRequest)
            XCTFail()
        } catch let error as PayPalSDKError {
            XCTAssertEqual(error.domain, APIClientError.domain)
            XCTAssertEqual(error.code, APIClientError.Code.dataParsingError.rawValue)
            XCTAssertEqual(error.localizedDescription, "An error occured parsing HTTP response data. Contact developer.paypal.com/support.")
        } catch {
            XCTFail("Unexpected error type")
        }
    }

    func testFetch_whenBadStatusCode_withErrorData_returnsReadableErrorMessage() async {
        let jsonResponse = """
        {
            "name": "ERROR_NAME",
            "message": "The requested action could not be performed."
        }
        """

        mockURLSession.cannedJSONData = jsonResponse

        mockURLSession.cannedURLResponse = HTTPURLResponse(
            // swiftlint:disable:next force_unwrapping
            url: URL(string: "www.fake.com")!,
            statusCode: 500,
            httpVersion: "1",
            headerFields: [:]
        )

        do {
            _ = try await apiClient.fetch(endpoint: fakeRequest)
            XCTFail()
        } catch let error as PayPalSDKError {
            XCTAssertEqual(error.domain, APIClientError.domain)
            XCTAssertEqual(error.code, APIClientError.Code.serverResponseError.rawValue)
            XCTAssertEqual(error.localizedDescription, "ERROR_NAME: The requested action could not be performed.")
        } catch {
            XCTFail("Unexpected error type")
        }
    }

    func testFetch_whenBadStatusCode_withoutErrorData_returnsUnknownError() async {
        mockURLSession.cannedJSONData = ""

        mockURLSession.cannedURLResponse = HTTPURLResponse(
            // swiftlint:disable:next force_unwrapping
            url: URL(string: "www.fake.com")!,
            statusCode: 500,
            httpVersion: "1",
            headerFields: [:]
        )

        do {
            _ = try await apiClient.fetch(endpoint: fakeRequest)
            XCTFail()
        } catch let error as PayPalSDKError {
            XCTAssertEqual(error.domain, APIClientError.domain)
            XCTAssertEqual(error.code, APIClientError.Code.unknown.rawValue)
            XCTAssertEqual(error.localizedDescription, "An unknown error occured. Contact developer.paypal.com/support.")
        } catch {
            XCTFail("Unexpected error type")
        }
    }

    func testFetch_whenPayPalDebugHeader_returnsCorrelationID() async {
        let jsonResponse = """
        {
            "scope": "fake-scope",
            "access_token": "fake-token",
            "token_type": "fake-bearer",
            "expires_in": 1,
            "nonce": "fake-nonce"
        }
        """

        mockURLSession.cannedJSONData = jsonResponse
        mockURLSession.cannedURLResponse = HTTPURLResponse(
            // swiftlint:disable:next force_unwrapping
            url: URL(string: "www.fake.com")!,
            statusCode: 200,
            httpVersion: "1",
            headerFields: ["Paypal-Debug-Id": "fake-id"]
        )

        let accessTokenRequest = AccessTokenRequest(clientID: "")
        do {
            let (_, correlationID) = try await apiClient.fetch(endpoint: accessTokenRequest)
            XCTAssertEqual(correlationID, "fake-id")
        } catch {
            XCTFail("Unexpected error")
        }
    }
}
