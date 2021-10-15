//
//  HttpClient_Tests.swift
//  PaymentsCoreTests
//
//  Created by Shropshire, Steven on 10/15/21.
//

import XCTest
@testable import PaymentsCore
@testable import TestShared

class HttpClient_Tests: XCTestCase {
    
    private let url = URL(string: "www.test.com")!
    private var urlSession: MockURLSession!
    
    private var sut: HttpClient!
    
    override func setUp() {
        urlSession = MockURLSession()
        sut = HttpClient(urlSession: urlSession)
    }
    
    func testSend_performsURLRequest() {
        let urlRequest = URLRequest(url: url)
        sut.send(urlRequest) { _ in }
        
        XCTAssertEqual(urlRequest, urlSession.lastPerformedRequest)
    }
    
    func testSend_callbackHttpResponse() {
        let headerFields: [String: String] = [ "Sample-Header" : "Sample-Value" ]
        let successURLResponse = HTTPURLResponse(url: url,
                                          statusCode: 200,
                                         httpVersion: "https",
                                        headerFields: headerFields)

        urlSession.cannedURLResponse = successURLResponse
        urlSession.cannedJSONData = """
            { "json": "data" }
        """
        
        let expect = expectation(description: "callback http response")
        sut.send(URLRequest(url: url)) { response in
            XCTAssertEqual(200, response.status)
            XCTAssertEqual(headerFields, response.headers as! [String: String])
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
