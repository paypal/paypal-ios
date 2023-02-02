import XCTest
@testable import CorePayments

class GetClientIDRequest_Tests: XCTestCase {

    func test_httpParameters() throws {
        let sampleToken = "sample_token"
        let request = GetClientIDRequest(accessToken: sampleToken)

        let expectedPath = "v1/oauth2/token"
        let expectedMethod = HTTPMethod.get
        let expectedHeaders: [HTTPHeader: String] = [
            .contentType: "application/json",
            .acceptLanguage: "en_US",
            .authorization: "Bearer sample_token"
        ]

        XCTAssertNil(request.body)
        XCTAssertEqual(request.path, expectedPath)
        XCTAssertEqual(request.method, expectedMethod)
        XCTAssertEqual(request.headers, expectedHeaders)
    }
}
