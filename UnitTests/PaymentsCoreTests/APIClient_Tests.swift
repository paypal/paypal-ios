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

    // MARK: - fetch() tests

    // TODO: This test is specific to AccessToken, move it out of this file.
    func testFetch_whenAccessTokenSuccessResponse_returnsValidAccessToken() {
        let expect = expectation(description: "Callback invoked.")

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

        apiClient.fetch(endpoint: accessTokenRequest) { result, _ in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.accessToken, "fake-token")
                XCTAssertEqual(response.nonce, "fake-nonce")
                XCTAssertEqual(response.scope, "fake-scope")
                XCTAssertEqual(response.tokenType, "fake-bearer")
                XCTAssertEqual(response.expiresIn, 1)
            case .failure:
                XCTFail("Expect success response")
            }

            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testFetch_withNoURLRequest_returnsInvalidURLRequestError() {
        let expect = expectation(description: "Callback invoked.")

        // Mock request whose API object does not vend a URLRequest
        let noURLRequest = FakeRequestNoURL()

        apiClient.fetch(endpoint: noURLRequest) { result, _ in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error.domain, APIClientError.domain)
                XCTAssertEqual(error.code, APIClientError.Code.invalidURLRequest.rawValue)
                XCTAssertEqual(error.localizedDescription, "An error occured constructing an HTTP request. Contact developer.paypal.com/support.")
            }

            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testFetch_whenServerError_returnsURLSessionError() {
        let expect = expectation(description: "Callback invoked.")
        let serverError = NSError(
            domain: URLError.errorDomain,
            code: NSURLErrorBadServerResponse,
            userInfo: [NSLocalizedDescriptionKey: "fake-error"]
        )

        mockURLSession.cannedError = serverError

        apiClient.fetch(endpoint: fakeRequest) { result, _ in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error.domain, APIClientError.domain)
                XCTAssertEqual(error.code, APIClientError.Code.urlSessionError.rawValue)
                XCTAssertEqual(error.localizedDescription, "fake-error")
            }

            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testFetch_whenNoURLResponse_returnsInvalidURLResponseError() {
        let expect = expectation(description: "Callback invoked.")

        mockURLSession.cannedURLResponse = nil

        apiClient.fetch(endpoint: fakeRequest) { result, _ in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error.domain, APIClientError.domain)
                XCTAssertEqual(error.code, APIClientError.Code.invalidURLResponse.rawValue)
                XCTAssertEqual(error.localizedDescription, "An error occured due to an invalid HTTP response. Contact developer.paypal.com/support.")
            }

            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testFetch_whenNoResponseData_returnsMissingDataError() {
        let expect = expectation(description: "Callback invoked.")

        mockURLSession.cannedURLResponse = successURLResponse

        apiClient.fetch(endpoint: fakeRequest) { result, _ in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error.domain, APIClientError.domain)
                XCTAssertEqual(error.code, APIClientError.Code.noResponseData.rawValue)
                XCTAssertEqual(error.localizedDescription, "An error occured due to missing HTTP response data. Contact developer.paypal.com/support.")
            }

            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testFetch_whenInvalidData_returnsParseError() {
        let expect = expectation(description: "Callback invoked.")

        mockURLSession.cannedURLResponse = successURLResponse
        mockURLSession.cannedJSONData = "{ \"test\" : \"bad-format\" }"

        apiClient.fetch(endpoint: fakeRequest) { result, _ in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error.domain, APIClientError.domain)
                XCTAssertEqual(error.code, APIClientError.Code.dataParsingError.rawValue)
                XCTAssertEqual(error.localizedDescription, "An error occured parsing HTTP response data. Contact developer.paypal.com/support.")
            }

            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testFetch_whenBadStatusCode_withErrorData_returnsReadableErrorMessage() {
        let expect = expectation(description: "Callback invoked.")

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

        apiClient.fetch(endpoint: fakeRequest) { result, _ in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error.domain, APIClientError.domain)
                XCTAssertEqual(error.code, APIClientError.Code.serverResponseError.rawValue)
                XCTAssertEqual(error.localizedDescription, "ERROR_NAME: The requested action could not be performed.")
            }

            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testFetch_whenBadStatusCode_withoutErrorData_returnsUnknownError() {
        let expect = expectation(description: "Callback invoked.")

        mockURLSession.cannedJSONData = ""

        mockURLSession.cannedURLResponse = HTTPURLResponse(
            // swiftlint:disable:next force_unwrapping
            url: URL(string: "www.fake.com")!,
            statusCode: 500,
            httpVersion: "1",
            headerFields: [:]
        )

        apiClient.fetch(endpoint: fakeRequest) { result, _ in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error.domain, APIClientError.domain)
                XCTAssertEqual(error.code, APIClientError.Code.unknown.rawValue)
                XCTAssertEqual(error.localizedDescription, "An unknown error occured. Contact developer.paypal.com/support.")
            }

            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testFetch_whenPayPalDebugHeader_returnsCorrelationID() {
        let expect = expectation(description: "Callback invoked.")

        mockURLSession.cannedURLResponse = HTTPURLResponse(
            // swiftlint:disable:next force_unwrapping
            url: URL(string: "www.fake.com")!,
            statusCode: 200,
            httpVersion: "1",
            headerFields: ["Paypal-Debug-Id": "fake-id"]
        )

        apiClient.fetch(endpoint: fakeRequest) { _, correlationID in
            XCTAssertEqual(correlationID, "fake-id")
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
