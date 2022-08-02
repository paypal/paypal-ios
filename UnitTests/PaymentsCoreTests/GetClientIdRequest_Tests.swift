import XCTest
@testable import PaymentsCore

class GetClientIdRequest_Tests: XCTestCase {

    func test_httpParameters() throws {
        let sampleToken = "sample_token"
        let getClientIdRequest = GetClientIdRequest(token: sampleToken)

        let expectedPath = "v1/oauth2/token"
        let expectedMethod = HTTPMethod.get
        let expectedHeaders: [HTTPHeader: String] = [
            .contentType: "application/json",
            .acceptLanguage: "en_US",
            .authorization: "Bearer sample_token"
        ]

        XCTAssertNil(getClientIdRequest.body)
        XCTAssertEqual(getClientIdRequest.path, expectedPath)
        XCTAssertEqual(getClientIdRequest.method, expectedMethod)
        XCTAssertEqual(getClientIdRequest.headers, expectedHeaders)
    }
}
