//
//  APIRequestTests.swift
//  APIRequestTests
//
//  Created by Jones, Jon on 9/20/21.
//

import Foundation
@testable import PaymentsCore
import XCTest

class AccessTokenRequest_Tests: XCTestCase {
    func testAccessTokenRequest_toURLRequest_vendsCorrectURLString() throws {
        let expectedUrl = "https://api.sandbox.paypal.com/v1/oauth2/token"
        let environment = Environment.sandbox

        let testClientId = "testClientId"
        let accessTokenRequest = AccessTokenRequest(clientID: testClientId)

        let urlRequest = try XCTUnwrap(accessTokenRequest.toURLRequest(environment: environment))
   
        XCTAssertEqual(urlRequest.url?.absoluteString, expectedUrl)
    }
}
