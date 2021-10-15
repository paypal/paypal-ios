import XCTest
@testable import PaymentsCore
@testable import TestShared

class APIClient_Tests2: XCTestCase {
    
    struct APIRequestBodyMock: APIRequestBody, Decodable {
        let property: String
    }
    
    private var sandboxConfig = CoreConfig(clientID: "123", environment: .sandbox)
    private var productionConfig = CoreConfig(clientID: "123", environment: .production)
    
    private var http: HttpClientMock!
    
    override func setUp() {
        http = HttpClientMock()
    }
    
    func testSend_properlyResolvesSandboxURLs() {
        let sut = APIClient2(config: sandboxConfig, http: http)
        
        let apiRequest = APIRequest2(method: .post, path: "/sample/url")
        sut.send(apiRequest) { _ in }
        
        let urlRequest = http.lastSentRequest!
        XCTAssertEqual(URL(string: "https://api.sandbox.paypal.com/sample/url"), urlRequest.url)
    }
    
    func testSend_properlyResolvesProductionURLs() {
        let sut = APIClient2(config: productionConfig, http: http)
        
        let apiRequest = APIRequest2(method: .post, path: "/sample/url")
        sut.send(apiRequest) { _ in }
        
        let urlRequest = http.lastSentRequest!
        XCTAssertEqual(URL(string: "https://api.paypal.com/sample/url"), urlRequest.url)
    }
    
    func testSend_properlySetsHttpMethod() {
        let sut = APIClient2(config: sandboxConfig, http: http)
        
        let apiRequest = APIRequest2(method: .post, path: "/sample/url")
        sut.send(apiRequest) { _ in }
        
        let urlRequest = http.lastSentRequest!
        XCTAssertEqual("POST", urlRequest.httpMethod)
    }
    
    func testSend_properlySetsHttpBody() {
        let sut = APIClient2(config: sandboxConfig, http: http)
        
        var apiRequest = APIRequest2(method: .post, path: "/sample/url")
        apiRequest.body = APIRequestBodyMock(property: "value")
        
        sut.send(apiRequest) { _ in }
        let urlRequest = http.lastSentRequest!
        let httpBody = urlRequest.httpBody!
        
        let decoder = JSONDecoder()
        let payloadMock = try! decoder.decode(APIRequestBodyMock.self, from: httpBody)
        XCTAssertEqual("value", payloadMock.property)
    }
    
    func testSend_setsContentTypeHeaderToJSON() {
        let sut = APIClient2(config: sandboxConfig, http: http)
        
        let apiRequest = APIRequest2(method: .post, path: "/sample/url")
        
        sut.send(apiRequest) { _ in }
        let urlRequest = http.lastSentRequest!
        
        XCTAssertEqual("application/json", urlRequest.value(forHTTPHeaderField: "Content-Type"))
    }
    
    func testSend_setsAcceptLanguageHeaderToEN() {
        let sut = APIClient2(config: sandboxConfig, http: http)
        
        let apiRequest = APIRequest2(method: .post, path: "/sample/url")
        
        sut.send(apiRequest) { _ in }
        let urlRequest = http.lastSentRequest!
        
        XCTAssertEqual("en_US", urlRequest.value(forHTTPHeaderField: "Accept-Language"))
    }
    
    func testSend_setsAuthenticationHeaderToBasicAuthWithClientID() {

        let sut = APIClient2(config: sandboxConfig, http: http)
        
        let apiRequest = APIRequest2(method: .post, path: "/sample/url")
        
        sut.send(apiRequest) { _ in }
        let urlRequest = http.lastSentRequest!
        
        XCTAssertEqual("Basic MTIzOg==", urlRequest.value(forHTTPHeaderField: "Authorization"))
    }
    
    func testSend_forwardsHTTPResponseToCompletionHandler() {
        let httpResponse = HttpResponse(status: 123)
        http.stubSend(with: httpResponse)
        
        let sut = APIClient2(config: sandboxConfig, http: http)
        
        let apiRequest = APIRequest2(method: .post, path: "/sample/url")
        
        let expect = expectation(description: "forwards http response to completion handler")
        sut.send(apiRequest) { response in
            XCTAssertEqual(123, response.status)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
