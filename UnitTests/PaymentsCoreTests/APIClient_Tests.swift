import XCTest
@testable import CorePayments
@testable import TestShared

class APIClient_Tests: XCTestCase {

    // MARK: - Helper Properties

    var sut: APIClient!
    let mockHTTP = MockHTTP()

    // MARK: - Test lifecycle

    override func setUp() {
        super.setUp()
        
        sut = APIClient(http: mockHTTP)
    }
    
    // MARK: - fetch()
    
    func testFetch_forwardsAPIRequestToHTTPClass() async throws {
        _ = try? await sut.fetch(request: FakeRequest())
        
        XCTAssert(mockHTTP.lastAPIRequest is FakeRequest)
        XCTAssertEqual(mockHTTP.lastAPIRequest?.path, "/fake-path")
    }
    
    // todo - Should these be in a test file for the HTTPResponseParser instead?
    func testFetch_whenBadStatusCode_withErrorData_returnsReadableErrorMessage() async {
        let jsonResponse = """
        {
            "name": "ERROR_NAME",
            "message": "The requested action could not be performed."
        }
        """
        mockHTTP.stubHTTPResponse = HTTPResponse(status: 500, body: jsonResponse.data(using: .utf8)!)
        
        do {
            _ =  try await sut.fetch(request: FakeRequest())
            XCTFail("Request succeeded. Expected error.")
        } catch let error as CoreSDKError {
            XCTAssertEqual(error.domain, APIClientError.domain)
            XCTAssertEqual(error.code, APIClientError.Code.serverResponseError.rawValue)
            XCTAssertEqual(error.localizedDescription, "ERROR_NAME: The requested action could not be performed.")
        } catch let error {
            XCTFail("Unexpected error type")
        }
    }

    func testFetch_whenBadStatusCode_withoutErrorData_returnsUnknownError() async {
        mockHTTP.stubHTTPResponse = HTTPResponse(status: 500, body: nil)

        do {
            _ = try await sut.fetch(request: FakeRequest())
            XCTFail("Request succeeded. Expected error.")
        } catch let error as CoreSDKError {
            XCTAssertEqual(error.domain, APIClientError.domain)
            XCTAssertEqual(error.code, APIClientError.Code.unknown.rawValue)
            XCTAssertEqual(error.localizedDescription, "An unknown error occured. Contact developer.paypal.com/support.")
        } catch {
            XCTFail("Unexpected error type")
        }
    }
    
    // test when status code bad & error body, parses
    
    // test when status code bad & no error body, returns X error
    
    // test when missing body data, returns no body data
    
    // test when body data & success code, parses body
    
    // test when body data bad & success code,
    
    // MARK: - fetchCachedOrRemoteClientID()

    func testGetClientID_successfullyReturnsData() async throws {
        mockHTTP.stubHTTPResponse = HTTPResponse(status: 200, body: #"{ "client_id": "sample_id" }"#.data(using: .utf8)!)
        
        let response = try await sut.fetchCachedOrRemoteClientID()
        XCTAssertEqual(response, "sample_id")
    }
}
