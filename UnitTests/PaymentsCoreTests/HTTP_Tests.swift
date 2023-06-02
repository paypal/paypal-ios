import XCTest
@testable import CorePayments
@testable import TestShared

class HTTP_Tests: XCTestCase {
    
    // MARK: - Helper Properties
    
    var fakeRequest = FakeRequest()
    
    let config = CoreConfig(accessToken: "mockAccessToken", environment: .sandbox)
    var mockURLSession: MockURLSession!
    var sut: HTTP!
    
    // MARK: - Test lifecycle
    
    override func setUp() {
        super.setUp()
                
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

    func testPerformRequest_withNoURLRequest_returnsInvalidURLRequestError() async {
        // Mock request whose API object does not vend a URLRequest
        let noURLRequest = FakeRequestNoURL()

        do {
            _ = try await sut.performRequest(noURLRequest)
            XCTFail("This should have failed.")
        } catch let error as CoreSDKError {
            XCTAssertEqual(error.domain, APIClientError.domain)
            XCTAssertEqual(error.code, APIClientError.Code.invalidURLRequest.rawValue)
            XCTAssertEqual(error.localizedDescription, "An error occured constructing an HTTP request. Contact developer.paypal.com/support.")
        } catch {
            XCTFail("Unexpected error type")
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
            _ = try await sut.performRequest(fakeRequest)
            XCTFail("Request succeeded. Expected error.")
        } catch let error {
            XCTAssertTrue(serverError === (error as AnyObject))
        }
    }
    
    func testPerformRequest_whenResponseCastFails_returnsError() async {
        mockURLSession.cannedURLResponse = URLResponse()
        
        do {
            _ = try await sut.performRequest(fakeRequest)
            XCTFail("Request succeeded. Expected error.")
        } catch let error as CoreSDKError {
            XCTAssertEqual(error.domain, APIClientError.domain)
            XCTAssertEqual(error.code, APIClientError.Code.invalidURLResponse.rawValue)
            XCTAssertEqual(error.localizedDescription, "An error occured due to an invalid HTTP response. Contact developer.paypal.com/support.")
        } catch {
            XCTFail("Unexpected error type")
        }
    }
}
