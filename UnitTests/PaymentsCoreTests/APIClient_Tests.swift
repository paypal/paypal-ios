import XCTest
@testable import CorePayments
@testable import TestShared

class APIClient_Tests: XCTestCase {

    // MARK: - Helper Properties

    let successURLResponse = HTTPURLResponse(url: URL(string: "www.test.com")!, statusCode: 200, httpVersion: "https", headerFields: [:])
    let fakeRequest = FakeRequest()

    let config = CoreConfig(accessToken: "mockAccessToken", environment: .sandbox)
    var mockURLSession: MockURLSession!
    var sut: APIClient!
    let mockHTTP = MockHTTP()

    // MARK: - Test lifecycle

    override func setUp() {
        super.setUp()
        mockURLSession = MockURLSession()
        
        sut = APIClient(http: mockHTTP)
    }
    
    // MARK: - fetch()
    
    func testFetch_forwardsAPIRequestToHTTPClass() async throws {
        let fakeRequest = FakeRequest()
                
        _ = try await sut.fetch(request: fakeRequest)
        
        XCTAssert(mockHTTP.lastAPIRequest is FakeRequest)
        XCTAssertEqual(mockHTTP.lastAPIRequest?.path, "/fake-path")
    }
    
    // MARK: - fetchCachedOrRemoteClientID()

    func testGetClientID_successfullyReturnsData() async throws {
        mockHTTP.stubHTTPResponse = HTTPResponse(status: 200, body: #"{ "client_id": "sample_id" }"#.data(using: .utf8)!)
        
        let response = try await sut.fetchCachedOrRemoteClientID()
        XCTAssertEqual(response, "sample_id")
    }
}
