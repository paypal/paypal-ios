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
    
//    func testGetClientId_successfullyReturnsData() {
//        if let jsonResponse = CardResponses.confirmPaymentSourceJson.rawValue.data(using: String.Encoding.utf8) {
//            let mockResponse = MockResponse.success(
//                MockResponse.Success(data: jsonResponse, urlResponse: successURLResponse)
//            )
//            mockURLSession.addResponse(mockResponse)
//            let expectation = expectation(description: "testName")
//
//            let cardRequest = CardRequest(orderID: "testOrderId", card: card)
//
//            let mockCardDelegate = MockCardDelegate(success: {_, result -> Void in
//                XCTAssertEqual(result.orderID, "testOrderId")
//                XCTAssertEqual(result.paymentSource?.card.brand, "VISA")
//                XCTAssertEqual(result.paymentSource?.card.lastFourDigits, "7321")
//                XCTAssertEqual(result.paymentSource?.card.type, "CREDIT")
//                expectation.fulfill()
//            }, error: { _, _ -> Void in
//                XCTFail()
//            }, threeDSWillLaunch: { _ -> Void in
//                XCTFail()
//            })
//
//            cardClient.delegate = mockCardDelegate
//
//            cardClient.start(
//                request: cardRequest,
//                context: MockViewController(),
//                webAuthenticationSession: MockWebAuthenticationSession()
//            )
//
//            waitForExpectations(timeout: 10)
//        } else {
//            XCTFail("Data json cannot be null")
//        }
//    }
    
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
