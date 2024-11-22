import XCTest
@testable import CorePayments
@testable import TestShared

class HTTP_Tests: XCTestCase {
    
    // MARK: - Helper Properties
    
    let fakePostData = #"{ "fake": "data" }"#.data(using: .utf8)
    var fakeHTTPRequest: HTTPRequest!
    
    let config = CoreConfig(clientID: "mockClientID", environment: .sandbox)
    var mockURLSession: MockURLSession!
    var sut: HTTP!
    
    // MARK: - Test lifecycle
    
    override func setUp() {
        super.setUp()
        
        fakeHTTPRequest = HTTPRequest(headers: [.appName: "fake-app"], method: .get, url: URL(string: "www.fake.com")!, body: fakePostData)

        mockURLSession = MockURLSession()
        mockURLSession.cannedError = nil
        mockURLSession.cannedURLResponse = nil
        mockURLSession.cannedJSONData = nil
        
        sut = HTTP(
            urlSession: mockURLSession,
            coreConfig: config
        )
    }
    
    // MARK: - performRequest()

    func testPerformRequest_configuresURLRequest() async {
        do {
            _ = try await sut.performRequest(fakeHTTPRequest)
            XCTAssertEqual(mockURLSession.capturedURLRequest?.url?.absoluteString, "www.fake.com")
            XCTAssertEqual(mockURLSession.capturedURLRequest?.httpMethod, "GET")
            XCTAssertEqual(mockURLSession.capturedURLRequest?.allHTTPHeaderFields, ["x-app-name": "fake-app"])
            XCTAssertEqual(mockURLSession.capturedURLRequest?.httpBody, fakePostData)
        } catch {
            XCTFail("Unexpected failure.")
        }
    }

    func testPerformRequest_whenServerError_returnsURLSessionError() async {
        let serverError = NSError(
            domain: URLError.errorDomain,
            code: NSURLErrorBadServerResponse,
            userInfo: [NSLocalizedDescriptionKey: "fake-error"]
        )

        mockURLSession.cannedError = serverError

        do {
            _ = try await sut.performRequest(fakeHTTPRequest)
            XCTFail("Request succeeded. Expected error.")
        } catch let error as CoreSDKError {
            XCTAssertEqual(error.domain, NetworkingError.domain)
            XCTAssertEqual(error.code, NetworkingError.Code.urlSessionError.rawValue)
            XCTAssertEqual(error.localizedDescription, "An error occured during network call. Contact developer.paypal.com/support.")
        } catch {
            XCTFail("Unexpected error type")
        }
    }
    
    func testPerformRequest_whenResponseCastFails_returnsError() async {
        mockURLSession.cannedURLResponse = URLResponse()
        
        do {
            _ = try await sut.performRequest(fakeHTTPRequest)
            XCTFail("Request succeeded. Expected error.")
        } catch let error as CoreSDKError {
            XCTAssertEqual(error.domain, NetworkingError.domain)
            XCTAssertEqual(error.code, NetworkingError.Code.invalidURLResponse.rawValue)
            XCTAssertEqual(error.localizedDescription, "An error occured due to an invalid HTTP response. Contact developer.paypal.com/support.")
        } catch {
            XCTFail("Unexpected error type")
        }
    }
    
    func testPerformRequest_formatsAndReturnsHTTPResponse() async {
        let fakeJSONResponseString = #"{ "fake": "response-data" }"#
        mockURLSession.cannedURLResponse = HTTPURLResponse(url: URL(string: "www.fake.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        mockURLSession.cannedJSONData = fakeJSONResponseString
        
        do {
            let httpResponse = try await sut.performRequest(fakeHTTPRequest)
            XCTAssertEqual(httpResponse.status, 200)
            XCTAssertTrue(httpResponse.isSuccessful)
            XCTAssertEqual(httpResponse.body, fakeJSONResponseString.data(using: .utf8))
        } catch {
            XCTFail("Unexpected failure.")
        }
    }
}
