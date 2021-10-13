import XCTest
@testable import PaymentsCore
@testable import TestShared

class APIClient_Tests: XCTestCase {

    // MARK: - Helper Properties
    
    let successURLResponse = HTTPURLResponse(url: URL(string: "www.test.com")!, statusCode: 200, httpVersion: "https", headerFields: [:])
    let config = CoreConfig(clientID: "", environment: .sandbox)
    let fakeRequest = FakeRequest()
    
    var mockURLSession: MockURLSession!
    var apiClient: APIClient!
    
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
            case .failure(_):
                XCTFail("Expect success response")
            }

            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
        
    func testFetch_whenServerError_returnsConnectionError() {
        let expect = expectation(description: "Callback invoked.")
        let serverError = NSError(
            domain: URLError.errorDomain,
            code: NSURLErrorBadServerResponse,
            userInfo: nil
        )

        mockURLSession.cannedError = serverError
        
        apiClient.fetch(endpoint: fakeRequest) { result, _ in
            switch result {
            case .success(_):
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error.domain, "PaymentsCoreErrorDomain")
                XCTAssertEqual(error.code, PaymentsCoreError.Code.connectionIssue.rawValue)
                XCTAssertEqual(error.localizedDescription, "todo")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

//    func testFetch_whenNoURLResponse_returnsInvalidURLResponseError() {
//        let expect = expectation(description: "Callback invoked.")
//
//        mockURLSession.cannedURLResponse = nil
//
//        apiClient.fetch(endpoint: fakeRequest) { result, _ in
//            guard case .failure(.invalidURLResponse) = result else {
//                XCTFail()
//                return
//            }
//
//            expect.fulfill()
//        }
//        waitForExpectations(timeout: 1)
//    }
//
//    func testFetch_whenNoResponseData_returnsMissingDataError() {
//        let expect = expectation(description: "Callback invoked.")
//
//        mockURLSession.cannedURLResponse = successURLResponse
//
//        apiClient.fetch(endpoint: fakeRequest) { result, _ in
//            guard case .failure(.noResponseData) = result else {
//                XCTFail()
//                return
//            }
//
//            expect.fulfill()
//        }
//        waitForExpectations(timeout: 1)
//    }
//
//    func testFetch_whenInvalidData_returnsParseError() {
//        let expect = expectation(description: "Callback invoked.")
//
//        let jsonResponse = """
//        {
//            "test": "wrong response format"
//        }
//        """
//
//        mockURLSession.cannedURLResponse = successURLResponse
//        mockURLSession.cannedJSONData = jsonResponse
//
//        apiClient.fetch(endpoint: fakeRequest) { result, _ in
//            switch result {
//            case .success(_):
//                XCTFail()
//            case .failure(let error):
//                XCTAssertNotNil(error)
//            }
//
//            expect.fulfill()
//        }
//        waitForExpectations(timeout: 1)
//    }
//
//    // TODO: Get more granual here. Also, do we want to move this check for
//    // non-success status code above data parsing in our source code?
//    func testFetch_whenBadStatusCode_returnsUnknownError() {
//        let expect = expectation(description: "Callback invoked.")
//
//        let jsonResponse = """
//        { "some": "json" }
//        """
//
//        mockURLSession.cannedJSONData = jsonResponse
//
//        mockURLSession.cannedURLResponse = HTTPURLResponse(
//            url: URL(string: "www.fake.com")!,
//            statusCode: 500,
//            httpVersion: "1",
//            headerFields: [:]
//        )
//
//        apiClient.fetch(endpoint: fakeRequest) { result, _ in
//            guard case .failure(.unknown) = result else {
//                XCTFail()
//                return
//            }
//
//            expect.fulfill()
//        }
//        waitForExpectations(timeout: 1)
//    }
//
//    func testFetch_whenPayPalDebugHeader_returnsCorrelationID() {
//        let expect = expectation(description: "Callback invoked.")
//
//        mockURLSession.cannedURLResponse = HTTPURLResponse(
//            url: URL(string: "www.fake.com")!,
//            statusCode: 200,
//            httpVersion: "1",
//            headerFields: ["Paypal-Debug-Id": "fake-id"]
//        )
//
//        apiClient.fetch(endpoint: fakeRequest) { _, correlationID in
//            XCTAssertEqual(correlationID, "fake-id")
//            expect.fulfill()
//        }
//        waitForExpectations(timeout: 1)
//    }
//
//    func testFetch_withNoURLRequest_returnsNoURLRequestError() {
//        let expect = expectation(description: "Callback invoked.")
//
//        // Mock request whose API object does not vend a URLRequest
//        let noURLRequest = FakeRequestNoURL()
//
//        apiClient.fetch(endpoint: noURLRequest) { result, _ in
//            switch result {
//            case .success(_):
//                XCTFail()
//            case .failure(let error):
//                XCTAssertNotNil(error)
//            }
//
//            expect.fulfill()
//        }
//        waitForExpectations(timeout: 1)
//    }

}
