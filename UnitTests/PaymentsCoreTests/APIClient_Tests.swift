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
    
    func testFetch_parsesHTTPResponse() async {
        let jsonResponse = #"{ "fake_param": "fake-response" }"#
        mockHTTP.stubHTTPResponse = HTTPResponse(status: 200, body: jsonResponse.data(using: .utf8)!)
        
        do {
            let response = try await sut.fetch(request: FakeRequest())
            XCTAssert((response as Any) is FakeResponse)
            XCTAssertEqual(response.fakeParam, "fake-response")
        } catch {
            XCTFail("Expected fetch() to succeed")
        }
    }
    
    // MARK: - fetchCachedOrRemoteClientID()

    func testGetClientID_successfullyReturnsData() async throws {
        mockHTTP.stubHTTPResponse = HTTPResponse(status: 200, body: #"{ "client_id": "sample_id" }"#.data(using: .utf8)!)
        
        let response = try await sut.fetchCachedOrRemoteClientID()
        XCTAssertEqual(response, "sample_id")
    }
}
