import XCTest
@testable import PaymentsCore
@testable import TestShared

class APIClient_Tests: XCTestCase {

    // MARK: - Helper Properties
    let mockClientId = "mockClientId"
    let mockAccessToken = "mockAccessToken"

    // swiftlint:disable:next force_unwrapping
    let successURLResponse = HTTPURLResponse(url: URL(string: "www.test.com")!, statusCode: 200, httpVersion: "https", headerFields: [:])
    let fakeRequest = FakeRequest()

    // swiftlint:disable implicitly_unwrapped_optional
    var config: CoreConfig!
    var mockURLSession: MockURLSession!
    var apiClient: APIClient!
    // swiftlint:enable implicitly_unwrapped_optional

    // MARK: - Test lifecycle

    override func setUp() {
        super.setUp()
        config = CoreConfig(accessToken: mockAccessToken, environment: .sandbox)
        mockURLSession = MockURLSession()
        mockURLSession.cannedError = nil
        mockURLSession.cannedURLResponse = nil
        mockURLSession.cannedJSONData = nil

        apiClient = APIClient(urlSession: mockURLSession, coreConfig: config)
    }
    
    func testGetClientId_successfullyReturnsData() async {
        mockURLSession.cannedJSONData = APIResponses.oauthTokenJson.rawValue
        mockURLSession.cannedURLResponse = successURLResponse
        
        let response = try! await apiClient.getClientId()
        XCTAssertEqual(response, "sample_id")
    }
    
    func testFetch_withNoURLRequest_returnsInvalidURLRequestError() async {
        // Mock request whose API object does not vend a URLRequest
        let noURLRequest = FakeRequestNoURL()

        do {
            _ = try await apiClient.fetch(endpoint: noURLRequest)
            XCTFail("This should have failed.")
        } catch let error as CoreSDKError {
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
        } catch let error as CoreSDKError {
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
        } catch let error as CoreSDKError {
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
        } catch let error as CoreSDKError {
            XCTAssertEqual(error.domain, APIClientError.domain)
            XCTAssertEqual(error.code, APIClientError.Code.unknown.rawValue)
            XCTAssertEqual(error.localizedDescription, "An unknown error occured. Contact developer.paypal.com/support.")
        } catch {
            XCTFail("Unexpected error type")
        }
    }
}
