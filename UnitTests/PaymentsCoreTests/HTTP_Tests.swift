import XCTest
@testable import PaymentsCore
@testable import TestShared

// swiftlint:disable force_unwrapping implicitly_unwrapped_optional force_cast
class HTTP_Tests: XCTestCase {
    
    // MARK: - Helper Properties
    
    var fakeRequest = FakeRequest()
    var fakeURLRequest = FakeRequest().toURLRequest(environment: .sandbox)!
    let mockAccessToken = "mockAccessToken"
    let successURLResponse = HTTPURLResponse(url: URL(string: "www.test.com")!, statusCode: 200, httpVersion: "https", headerFields: [:])!
    
    var config: CoreConfig!
    var mockURLCache: MockURLCache!
    var mockURLSession: MockURLSession!
    var sut: HTTP!
    
    // MARK: - Test lifecycle
    
    override func setUp() {
        super.setUp()
        
        config = CoreConfig(accessToken: mockAccessToken, environment: .sandbox)
        
        mockURLSession = MockURLSession()
        mockURLSession.cannedError = nil
        mockURLSession.cannedURLResponse = nil
        mockURLSession.cannedJSONData = nil
        
        mockURLCache = MockURLCache()

        sut = HTTP(
            urlSession: mockURLSession,
            urlCache: mockURLCache,
            coreConfig: config
        )
    }
    
    // MARK: - performRequest()
    
    func testPerformRequest_withoutCachingEnabled_sendsHTTPRequest() async throws {
        mockURLSession.cannedJSONData = #"{ "fake_param": "some_value" }"#
        
        _ = try await sut.performRequest(fakeRequest)
        XCTAssertEqual(mockURLSession.lastURLRequestPerformed?.url?.absoluteString, "https://api.sandbox.paypal.com/fake-path")
    }
    
    // MARK: - performRequest(withCaching: true)
    
    func testPerformRequestWithCaching_hasCachedValue_doesNotSendHTTPRequestAndReturnsCachedValue() async throws {
        let cachedURLResponse = CachedURLResponse(
            response: successURLResponse,
            data: #"{ "fake_param": "cached_value1" }"#.data(using: String.Encoding.utf8)!
        )
        mockURLCache.cannedCache = [fakeURLRequest: cachedURLResponse]
        
        let response = try await sut.performRequest(fakeRequest, withCaching: true)
        XCTAssertNil(mockURLSession.lastURLRequestPerformed?.url?.absoluteString)
        XCTAssertEqual(response.fakeParam, "cached_value1")
    }
    
    func testPerformRequestWithCaching_hasEmptyCache_sendsHTTPRequest() async throws {
        mockURLSession.cannedJSONData = #"{ "fake_param": "cached_value2" }"#

        _ = try await sut.performRequest(fakeRequest, withCaching: true)
        XCTAssertEqual(mockURLSession.lastURLRequestPerformed?.url?.absoluteString, "https://api.sandbox.paypal.com/fake-path")
    }
    
    func testPerformRequestWithCaching_hasEmptyCache_cachesHTTPResponse() async throws {
        mockURLSession.cannedJSONData = #"{ "fake_param": "cached_value2" }"#

        _ = try await sut.performRequest(fakeRequest, withCaching: true)
        
        let dataInCache = mockURLCache.cannedCache[fakeURLRequest]?.data
        XCTAssertNotNil(dataInCache)
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let decodedCacheData = try decoder.decode(FakeRequest.ResponseType.self, from: dataInCache!)
        
        XCTAssertEqual(decodedCacheData.fakeParam, "cached_value2")
    }
}
