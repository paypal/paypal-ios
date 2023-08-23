import XCTest
@testable import CorePayments
@testable import TestShared

class APIClient_Tests: XCTestCase {
    
    // MARK: - Helper Properties
    
    var sut: APIClient!
    var mockHTTP: MockHTTP!
    var coreConfig = CoreConfig(clientID: "fake-client-id", environment: .sandbox)
    let base64EncodedFakeClientID = "ZmFrZS1jbGllbnQtaWQ6" // "fake-client-id" encoded
    let stubHTTPResponse = HTTPResponse(status: 200, body: nil)
    
    // MARK: - Test lifecycle
    
    override func setUp() {
        super.setUp()
        
        mockHTTP = MockHTTP(coreConfig: coreConfig)
        mockHTTP.stubHTTPResponse = stubHTTPResponse
        sut = APIClient(http: mockHTTP)
    }
    
    // MARK: - fetch() REST
    
    func testFetchREST_whenLive_usesProperPayPalURL() async throws {
        let mockHTTP = MockHTTP(coreConfig: CoreConfig(clientID: "123", environment: .live))
        mockHTTP.stubHTTPResponse = HTTPResponse(status: 200, body: nil)
        let sut = APIClient(http: mockHTTP)
        
        let fakeGETRequest = RESTRequest(path: "", method: .get)
        
        _ = try await sut.fetch(request: fakeGETRequest)
        XCTAssertEqual(mockHTTP.capturedHTTPRequest?.url.absoluteString, "https://api.paypal.com/")
    }
    
    func testFetchREST_whenSandbox_usesProperPayPalURL() async throws {
        let fakeGETRequest = RESTRequest(path: "", method: .get)
        
        _ = try await sut.fetch(request: fakeGETRequest)
        XCTAssertEqual(mockHTTP.capturedHTTPRequest?.url.absoluteString, "https://api.sandbox.paypal.com/")
    }
    
    func testFetchREST_whenGET_constructsProperHTTPRequest() async throws {
        let fakeGETRequest = RESTRequest(path: "v1/fake-endpoint", method: .get, queryParameters: ["key1": "value1"])
        
        _ = try await sut.fetch(request: fakeGETRequest)
        XCTAssertEqual(mockHTTP.capturedHTTPRequest?.url.absoluteString, "https://api.sandbox.paypal.com/v1/fake-endpoint?key1=value1")
        XCTAssertEqual(mockHTTP.capturedHTTPRequest?.method, .get)
        XCTAssertEqual(mockHTTP.capturedHTTPRequest?.headers[.authorization], "Basic \(base64EncodedFakeClientID)")
    }
    
    func testFetchREST_whenPOST_constructsProperHTTPRequest() async throws {
        let postBody = FakeRequest(fakeParam: "some-param")
        
        let fakePOSTRequest = RESTRequest(
            path: "v1/fake-endpoint",
            method: .post,
            postParameters: postBody
        )
        
        _ = try await sut.fetch(request: fakePOSTRequest)
        XCTAssertEqual(mockHTTP.capturedHTTPRequest?.url.absoluteString, "https://api.sandbox.paypal.com/v1/fake-endpoint")
        XCTAssertEqual(mockHTTP.capturedHTTPRequest?.method, .post)
        XCTAssertEqual(mockHTTP.capturedHTTPRequest?.headers[.authorization], "Basic \(base64EncodedFakeClientID)")
        XCTAssertEqual(mockHTTP.capturedHTTPRequest?.headers[.contentType], "application/json")
        
        let postData = mockHTTP.capturedHTTPRequest?.body
        let postJSON = try JSONSerialization.jsonObject(with: postData!, options: []) as! [String: Any]
        XCTAssertEqual(postJSON["fake_param"] as! String, "some-param")
    }
    
    func testFetchREST_returnsHTTPResponse() async throws {
        let fakeRequest = RESTRequest(path: "", method: .get)
        
        let result = try await sut.fetch(request: fakeRequest)
        XCTAssertEqual(result, stubHTTPResponse)
    }
    
    // MARK: - fetch() GraphQL
    
    func testFetchGraphQL_whenLive_usesProperPayPalURL() async throws {
        let mockHTTP = MockHTTP(coreConfig: CoreConfig(clientID: "123", environment: .live))
        mockHTTP.stubHTTPResponse = HTTPResponse(status: 200, body: nil)
        let sut = APIClient(http: mockHTTP)
        
        let fakeGraphQLRequest = GraphQLRequest(query: "fake-query", variables: FakeRequest(fakeParam: "fake-param"))
        
        _ = try await sut.fetch(request: fakeGraphQLRequest)
        XCTAssertEqual(mockHTTP.capturedHTTPRequest?.url.absoluteString, "https://paypal.com/graphql")
    }
    
    func testFetchGraphQL_whenSandbox_usesProperPayPalURL() async throws {
        let fakeGraphQLRequest = GraphQLRequest(query: "fake-query", variables: FakeRequest(fakeParam: "fake-param"))
        
        _ = try await sut.fetch(request: fakeGraphQLRequest)
        XCTAssertEqual(mockHTTP.capturedHTTPRequest?.url.absoluteString, "https://www.sandbox.paypal.com/graphql")
    }
    
    func testFetchGraphQL_constructsProperHTTPRequest() async throws {
        let fakeGraphQLRequest = GraphQLRequest(
            query: #"{ sample { query } }"#,
            variables: FakeRequest(fakeParam: "my-param")
        )
        
        _ = try await sut.fetch(request: fakeGraphQLRequest)
        XCTAssertEqual(mockHTTP.capturedHTTPRequest?.url.absoluteString, "https://www.sandbox.paypal.com/graphql")
        XCTAssertEqual(mockHTTP.capturedHTTPRequest?.method, .post)
        XCTAssertEqual(mockHTTP.capturedHTTPRequest?.headers[.accept], "application/json")
        XCTAssertEqual(mockHTTP.capturedHTTPRequest?.headers[.contentType], "application/json")
        XCTAssertEqual(mockHTTP.capturedHTTPRequest?.headers[.appName], "ppcpmobilesdk")
        XCTAssertEqual(mockHTTP.capturedHTTPRequest?.headers[.origin], coreConfig.environment.graphQLURL.absoluteString)
        
        let postData = mockHTTP.capturedHTTPRequest?.body
        let postJSON = try JSONSerialization.jsonObject(with: postData!, options: []) as! [String: Any]
        XCTAssertEqual(postJSON["query"] as! String, #"{ sample { query } }"#)
        XCTAssertNotNil(postJSON["variables"])
        XCTAssertEqual((postJSON["variables"] as! [String: String])["fakeParam"], "my-param")
    }
    
    func testFetchGraphQL_whenQueryNameSpecified_appendsToURL() async throws {
        let fakeGraphQLRequest = GraphQLRequest(
            query: "",
            variables: FakeRequest(fakeParam: "my-param"),
            queryNameForURL: "FakeName"
        )
        
        _ = try await sut.fetch(request: fakeGraphQLRequest)
        XCTAssertEqual(mockHTTP.capturedHTTPRequest?.url.absoluteString, "https://www.sandbox.paypal.com/graphql?FakeName")
    }
    
    func testFetchGraphQL_returnsHTTPResponse() async throws {
        let fakeGraphQLRequest = GraphQLRequest(query: "fake-query", variables: FakeRequest(fakeParam: "fake-param"))
        
        let result = try await sut.fetch(request: fakeGraphQLRequest)
        XCTAssertEqual(result, stubHTTPResponse)
    }
}

extension HTTPResponse: Equatable {
    
    public static func == (lhs: HTTPResponse, rhs: HTTPResponse) -> Bool {
        return lhs.body == rhs.body && lhs.isSuccessful == rhs.isSuccessful && lhs.status == rhs.status
    }
}
